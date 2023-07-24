USE FARMMANAGEMENT
GO
--============ DML COMMAND (INSERT, SELECT) ==============-- 
----INSERT INTO Farmers TABLE
INSERT INTO Farmers VALUES(1,'Siam','siam@gmail.com','01526640449')
INSERT INTO Farmers VALUES(2,'Rokon','Rokon@gmail.com','01826640449')
INSERT INTO Farmers VALUES(3,'Rakib','Rakib@gmail.com','01326640449')
INSERT INTO Farmers VALUES(4,'Omar','Omar@gmail.com','01926640449')
INSERT INTO Farmers VALUES(5,'Adil','Adil@gmail.com','01726640449')

----INSERT INTO Farms TABLE
INSERT INTO Farms VALUES(1,1,'Siam Farm','Barishal')
INSERT INTO Farms VALUES(2,2,'Rokon Farm','Khulna')
INSERT INTO Farms VALUES(3,3,'Asad Farm','Dhaka')
INSERT INTO Farms VALUES(4,4,'Rakib Farm','Cumilla')
INSERT INTO Farms VALUES(5,5,'Adil Farm','Narsingdi')

----INSERT INTO Crops TABLE
INSERT INTO Crops VALUES(1, 'Corn', 'Grain')
INSERT INTO Crops VALUES(2, 'Wheat', 'Grain')
INSERT INTO Crops VALUES(3, 'Rice', 'Grain')
INSERT INTO Crops VALUES(4, 'Jute', 'Fiber')
INSERT INTO Crops VALUES(5, 'Cotton', 'Fiber')

----INSERT INTO Planting TABLE
INSERT INTO Plantings VALUES(1, 1, 1,'Summer', '2023-06-01', 500.0)
INSERT INTO Plantings VALUES(2, 2, 3,'Winter', '2023-06-03', 300.0)
INSERT INTO Plantings VALUES(3, 4, 2,'Summer', '2023-06-02', 400.0)
INSERT INTO Plantings VALUES(4, 3, 5,'Summer', '2023-06-07', 400.0)
INSERT INTO Plantings VALUES(5, 5, 4,'Winter', '2023-06-05', 100.0)

/*SELECT */
Select * from Farmers
Select * from Farms
Select * from Crops
Select * from Plantings
--SP
EXEC SP_Farms 6, 'Summer';

/* DML COMMAND ( SELECT/DISTINCT/ORDER BY) */
SELECT * FROM Farmers
SELECT FarmerName,FarmerID From Farmers
SELECT DISTINCT Location From Farms
SELECT * FROM Farmers ORDER BY farmerName DESC

/* DML COMMAND UPDATE */
UPDATE Farmers SET farmerName ='Raihan'
WHERE FarmerID=1
Select * From Farmers
/* BACKUP FOR FARMERS */
SELECT * INTO farmerBackup From Farmers
/* DML COMMAND DELETE */
DELETE From Crops WHERE CropName='Cotton'
DELETE From Plantings

/* AGGREGRATE FUNCTIONS */
SELECT COUNT(farmerID),FarmerName From Farmers GROUP BY FarmerName
----AVERAGE OF quantity
Select PlantingID, AVG(quantity) as Avgequantity
From Plantings GROUP BY PlantingID
----Sum OF quantity
Select PlantingID, Sum(quantity) as Avgequantity
From Plantings GROUP BY PlantingID
----HAVING
SELECT COUNT(farmerID), FarmerName From Farmers GROUP BY FarmerName
HAVING COUNT (farmerID) > 1
----CUBE
SELECT farmerID, COUNT(farmerName) FROM Farmers GROUP BY CUBE (farmerID) ORDER BY farmerID
----ROLLUP
SELECT farmerID, COUNT(farmerName) FROM Farmers GROUP BY ROLLUP (farmerID)
----GROUPING SETS
SELECT PlantingID, PlantingSeason, Count(Quantity) From Plantings GROUP BY GROUPING SETS (PlantingID, PlantingSeason)
----USING LIKE
SELECT * FROM Farmers where farmername LIKE 'R%'

/* string functions */
SELECT CONCAT('Hello', ' ', 'World') AS Result;
SELECT LEN('Hello') AS Result;
SELECT SUBSTRING('Hello World', 7, 5) AS Result;
SELECT UPPER('hello') AS Result;
SELECT LOWER('WORLD') AS Result;
SELECT TRIM('   Hello   ') AS Result;
SELECT REPLACE('Hello World', 'World', 'John') AS Result;
SELECT CHARINDEX('World', 'Hello World') AS Result;
SELECT LEFT('Hello World', 5) AS Result;
SELECT RIGHT('Hello World', 5) AS Result;

/* Ranking Functions */
SELECT FarmerID, FarmerName, ROW_NUMBER() OVER (ORDER BY FarmerID) AS Rank FROM Farmers;
SELECT FarmerID, FarmerName, DENSE_RANK() OVER (ORDER BY FarmerID) AS Rank FROM Farmers;
SELECT FarmerID, FarmerName, RANK() OVER (ORDER BY FarmerID) AS Rank FROM Farmers;

/* UNION */
Select * From Farms
WHERE FarmID = 1
UNION 
Select * From Plantings
WHERE PlantingID = 1

/* MERGE */
MERGE INTO Plantings AS T
USING SourceTable AS S
ON (T.PlantingID = S.PlantingID)

WHEN MATCHED THEN
  UPDATE SET
    T.FarmID = S.FarmID,
    T.CropID = S.CropID,
    T.PlantingSeason = S.PlantingSeason,
    T.PlantingDate = S.PlantingDate,
    T.Quantity = S.Quantity

WHEN NOT MATCHED THEN
  INSERT (PlantingID, FarmID, CropID, PlantingSeason, PlantingDate, Quantity)
  VALUES (S.PlantingID, S.FarmID, S.CropID, S.PlantingSeason, S.PlantingDate, S.Quantity);

/* OFFSET FETCH */
SELECT * FROM farms
ORDER BY FarmID
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY

/* SUB QUERIES */
SELECT CropName
FROM Crops
WHERE CropType in ( SELECT CropType 
FROM Crops WHERE CropID = 2)
Order By CropID

/* JOIN */
SELECT F.FarmerName, FA.FarmName, C.CropName, P.PlantingSeason, P.PlantingDate, P.Quantity
FROM Farmers F
JOIN Farms FA ON F.FarmerID = FA.FarmerID
JOIN Plantings P ON FA.FarmID = P.FarmID
JOIN Crops C ON P.CropID = C.CropID;

----Joining with Where Clause & Order By
SELECT Farmers.FarmerName, Farms.FarmName, Plantings.PlantingSeason, Plantings.PlantingDate, Plantings.Quantity
FROM Farmers
JOIN Farms ON Farmers.FarmerID = Farms.FarmerID
JOIN Plantings ON Farms.FarmID = Plantings.FarmID
WHERE Farmers.FarmerName = 'Rokon'
Order By Plantings.PlantingDate

----Joining with Group By & Having Clause
SELECT Farmers.FarmerName, Farms.FarmName, COUNT(Plantings.PlantingID) AS TotalPlantings
FROM Farmers
JOIN Farms ON Farmers.FarmerID = Farms.FarmerID
JOIN Plantings ON Farms.FarmID = Plantings.FarmID
GROUP BY Farmers.FarmerName, Farms.FarmName
HAVING COUNT(Plantings.PlantingID) < 3;

/* CTE */
WITH MaxPlantingSeason AS (
  SELECT FarmID, MAX(PlantingSeason) AS MaxSeason
  FROM Plantings
  GROUP BY FarmID
)
SELECT Farms.FarmID, Farms.FarmName, MaxPlantingSeason.MaxSeason
FROM Farms
JOIN MaxPlantingSeason ON Farms.FarmID = MaxPlantingSeason.FarmID;

/* Case Function */
SELECT
  CropName,
  CASE
    WHEN CropType = 'Fruit' THEN 'Fruit Crop'
    WHEN CropType = 'Vegetable' THEN 'Vegetable Crop'
    ELSE 'Other Crop'
  END AS CropCategory
FROM Crops;
