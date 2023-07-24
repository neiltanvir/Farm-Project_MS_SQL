--============== CREATE FARM MANAGEMENT DATABASE ==============--

IF DB_ID('FARMMANAGEMENT') IS NOT NULL
DROP DATABASE FARMMANAGEMENT
GO

CREATE DATABASE  FARMMANAGEMENT
On
(
   Name='farmmmangement_data_1',
   Filename='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\farmmmangement_data_1.mdf',
   Size=20mb,
   Maxsize=100mb,
   Filegrowth=5%
)
Log On
(
   Name='farmmmangement_log_1',
   Filename='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\farmmmangement_log_1.ldf',
   Size=2mb,
   Maxsize=50mb,
   Filegrowth=1mb
)
GO

USE FARMMANAGEMENT
GO
--============== TABLE, CONSTRAINTS AND KEYS ============--
CREATE TABLE Farmers (
  FarmerID INT PRIMARY KEY,
  FarmerName VARCHAR(50),
  EmailAddress VARCHAR(100),
  Phone VARCHAR(20)
);
CREATE TABLE Farms (
  FarmID INT PRIMARY KEY,
  FarmerID INT REFERENCES Farmers(FarmerID),
  FarmName VARCHAR(100),
  Location VARCHAR(100)
);
CREATE TABLE Crops (
  CropID INT PRIMARY KEY,
  CropName VARCHAR(50),
  CropType VARCHAR(50)
);
CREATE TABLE Plantings (
  PlantingID INT PRIMARY KEY,
  FarmID INT REFERENCES Farms(FarmID),
  CropID INT REFERENCES Crops(CropID),
  PlantingSeason VARCHAR(50),
  PlantingDate DATE,
  Quantity Int
);


------Create Merge Table
CREATE TABLE SourceTable(
    PlantingID INT PRIMARY KEY,
	FarmID INT,
	CropID INT,
	PlantingSeason VARCHAR(50),
    PlantingDate DATE,
    Quantity Int);
	
------Create InPlant Table 
CREATE TABLE InPlant(
    PlantingID INT,
	PlantingSeason VARCHAR(50),
    Quantity Int,
	UpdatedBy NVARCHAR(100),
    UpdatedOn DATETIME)

--=========== DDL COMMAND : ALTER, DROP AND MODIFY TABLES & COLUMNS ==========--

ALTER TABLE Farmers ADD Farmer_age nvarchar(25);

ALTER TABLE Farmers DROP COLUMN Farmer_age

ALTER TABLE  Farms ALTER COLUMN Location nvarchar(80);

ALTER TABLE Farmers ADD UNIQUE(Phone)

ALTER TABLE Farms 
ADD CONSTRAINT Location
DEFAULT 'Dhaka' FOR Location

DROP TABLE Crops
DROP DATABASE FARMMANAGEMENT

--=========== CREATE CLUSTERED AND NONCLUSTERED INDEX ==========--
-- Clustered Index
CREATE CLUSTERED INDEX PK_Farmers_FarmerID
ON Farmers (FarmerID);

-- Nonclustered Index
CREATE NONCLUSTERED INDEX IX_Farmers_Phones
ON Farmers (Phone);

--============== CREATE A VIEW ============--
Go
CREATE VIEW VW_PlantingDetails
WITH SCHEMABINDING, ENCRYPTION
AS
SELECT P.PlantingID, F.FarmName, C.CropName, P.PlantingSeason, P.PlantingDate, P.Quantity
FROM dbo.Plantings P
JOIN dbo.Farms F ON P.FarmID = F.FarmID
JOIN dbo.Crops C ON P.CropID = C.CropID

--========== Create STORED PROCEDURE Using Parameter ============--
Go
CREATE PROCEDURE SP_Farms
  @PlantingID INT,
  @PlantingSeason VARCHAR(50)
AS
BEGIN
  SELECT PlantingID, PlantingSeason
  FROM Plantings
  WHERE PlantingID = @PlantingID AND PlantingSeason = @PlantingSeason
END;
Go
----Insert Data
CREATE PROCEDURE SP_InsertFarmer 
  @FarmerID INT,
  @FarmerName VARCHAR(50),
  @EmailAddress VARCHAR(100),
  @Phone VARCHAR(20)
AS
BEGIN
  INSERT INTO Farmers (FarmerID, FarmerName, EmailAddress, Phone)
  VALUES (@FarmerID, @FarmerName, @EmailAddress, @Phone);
END;
Go
----Update Data
CREATE PROCEDURE SP_UpdateCrop 
  @CropID INT,
  @CropName VARCHAR(50),
  @CropType VARCHAR(50)
AS
BEGIN
  UPDATE Crops
  SET CropName = @CropName,
      CropType = @CropType
  WHERE CropID = @CropID;
END;
Go
----Delete Data
CREATE PROCEDURE DeletePlanting 
  @PlantingID INT
AS
BEGIN
  DELETE FROM Plantings
  WHERE PlantingID = @PlantingID;
END;

--============ User-Defined Functions ==============--
----A SIMPLE TABLE VALUED FUNCTIONGOCREATE FUNCTION Fn_Crops()RETURNS TABLERETURN(SELECT CropID,Count(Croptype) AS CountCropFROM Cropsgroup by CropID)GoSELECT * FROM dbo.Fn_Crops()----A SCALAR FUNCTIONGoCREATE FUNCTION Fn_Farms()RETURNS INTBEGIN DECLARE @C INTSELECT @C=COUNT(*) FROM FarmsRETURN @CENDGoSELECT dbo.Fn_Farms()----A MULTISTATEMENT TABLE VALUED FUNCTIONGoCREATE FUNCTION Fn_FarmerPlantings()
RETURNS @FarmerPlantings TABLE
( FarmerID INT,
  FarmerName VARCHAR(50),
  PlantingSeason VARCHAR(50),
  PlantingDate DATE,
  Quantity INT)
AS
BEGIN
  INSERT INTO @FarmerPlantings
  SELECT F.FarmerID, F.FarmerName, P.PlantingSeason, P.PlantingDate, P.Quantity
  FROM Farmers F
  INNER JOIN Farms FR ON F.FarmerID = FR.FarmerID
  INNER JOIN Plantings P ON FR.FarmID = P.FarmID
RETURN
END
Go
SELECT * FROM dbo.Fn_FarmerPlantings()

--============ Create Trigger ==============-- 
----After trigger
Go
CREATE TRIGGER tr_plantings_insert
ON Plantings
AFTER UPDATE, INSERT
AS
BEGIN
INSERT INTO InPlant
SELECT i.PlantingID,i.PlantingSeason,Quantity,SUSER_NAME(),GETDATE()
FROM inserted i 
END
Go
SELECT * FROM InPlant

----Create Raiserror Trigger
Go
CREATE TRIGGER CheckPlantingQuantity
ON Plantings
INSTEAD OF INSERT, UPDATE
AS
BEGIN
  IF EXISTS (SELECT * FROM inserted WHERE Quantity < 0)
  BEGIN
    RAISERROR('Quantity cannot be negative.', 16, 1)
    ROLLBACK TRANSACTION
  END
  ELSE
  BEGIN
    INSERT INTO Plantings (PlantingID, FarmID, CropID, PlantingSeason, PlantingDate, Quantity)
    SELECT PlantingID, FarmID, CropID, PlantingSeason, PlantingDate, Quantity
    FROM inserted;
  END
END
