/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


-- THIS UPDATE IS NOT WORKING AFTER APPLYING UPDATE QUERY
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

SELECT *
FROM PortProject.dbo.NashvilleHousing

-- USING ALTER
-- Drop Column Using ALTER
ALTER TABLE NashvilleHousing
DROP COLUMN SalesDateConverted;

-- Not working...
UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(Date, SaleDate)

-- Use this to convert the type of SalesDate from (datetime to Date)
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;

SELECT *
FROM PortProject.dbo.NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


-- We found that if 2 or more ParcelID are same, then PropertyAddress for both are same as well.
SELECT *
FROM PortProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
order by ParcelID

-- To remove null, we can use ParcelId and UniqueID to replace null with same PropertyAddress.
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(B.PropertyAddress, A.PropertyAddress)
FROM PortProject.dbo.NashvilleHousing AS A
JOIN PortProject.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress is NULL


UPDATE B
SET PropertyAddress = ISNULL(B.PropertyAddress, A.PropertyAddress)
FROM PortProject.dbo.NashvilleHousing AS A
JOIN PortProject.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress is NULL

-- Proof that we are converting null cells into PropertyAddress using same ParcelId
SELECT *
FROM PortProject.dbo.NashvilleHousing
where PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortProject.dbo.NashvilleHousing

-- Using SUBSTRING we are going to split the property address into address and state.

SELECT 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as Address
FROM PortProject.dbo.NashvilleHousing

-- Create a first column called PropertySplitAddress
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

-- Update the column PropertySplitAddress and put starting address in this column
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) - 1)


-- Create a second column called PropertySplitCity
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

-- Update the column PropertySplitAddress and put starting address in this column
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

-- Drop Column PropertyAddress
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress; 

--SELECT *
--FROM PortProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Looking for OwnerAddress and applying PARSENAME which is more effective than SUBSTRING to split the column based on delimiter.

SELECT OwnerAddress
FROM PortProject.dbo.NashvilleHousing

-- Nothing will change because PARSENAME is useful with periods that's we need to use REPLACE to replace ',' with '.' and then use
-- PARSENAME()
--SELECT 
--PARSENAME(OwnerAddress, 1)
--FROM PortProject.dbo.NashvilleHousing
 
-- PARSENAME starts from right to left, that's we are doing 3,2 and 1.
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortProject.dbo.NashvilleHousing


-- Using ALTER and UPDATE, we are going to create 3 columns having OwnerAddress, OwnerState, OwnerCity.

-- Create a 1st column called PropertySplitCity
ALTER TABLE NashvilleHousing
ADD OwnerStreet Nvarchar(255);

-- Update the column PropertySplitAddress and put starting address in this column
UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


-- Create a 2nd column called PropertySplitCity
ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255);

-- Update the column PropertySplitAddress and put starting address in this column
UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


-- Create a 3rd column called PropertySplitCity
ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

-- Update the column PropertySplitAddress and put starting address in this column
UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortProject.dbo.NashvilleHousing


-- Populate Owner Address data that is split into OwnerStreet, OwnerState, OwnerCity.
-- DELETE all rows having null values.


DELETE 
FROM PortProject.dbo.NashvilleHousing 
where   OwnerStreet is NULL and
		OwnerState is NULL and
		OwnerCity is NULL


--SELECT *
--FROM PortProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Update the existing column instead of creating the new column
Update PortProject.dbo.NashvilleHousing
SET	SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
				   WHEN SoldAsVacant = 'N' then 'No'
				   ELSE SoldAsVacant
				   END
FROM PortProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Use row_number() window function to remove duplicates


WITH RowNumCTE AS (
select *,
	ROW_NUMBER() OVER(partition by 
					  ParcelID, 
					  PropertySplitAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
		 order by UniqueID) 
		 row_num
FROM PortProject.dbo.NashvilleHousing
)
-- Delete the records that contains row_num > 1
--Delete 
select *
from RowNumCTE
where row_num > 1;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortProject.dbo.NashvilleHousing

ALTER TABLE PortProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, SaleDate











-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO