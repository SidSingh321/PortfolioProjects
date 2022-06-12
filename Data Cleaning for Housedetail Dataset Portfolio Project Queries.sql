/* 
Cleaning Data using SQL queries
*/

SELECT *
FROM PortfolioProject..HouseDetails

--Standardizing Date Format

--Not Working
--UPDATE PortfolioProject..HouseDetails
--SET SaleDate = CONVERT(DATE, SaleDate)

SELECT SaleDate
FROM PortfolioProject..HouseDetails

--Used alter because it was not updating properly as normal update query.

ALTER TABLE PortfolioProject..HouseDetails
ADD SaleDateConverted Date;

UPDATE PortfolioProject..HouseDetails
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..HouseDetails

--Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject..HouseDetails
WHERE PropertyAddress is null

SELECT *
FROM PortfolioProject..HouseDetails
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.HouseDetails a
JOIN PortfolioProject.dbo.HouseDetails b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.HouseDetails a
JOIN PortfolioProject.dbo.HouseDetails b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..HouseDetails


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..HouseDetails

ALTER TABLE PortfolioProject..HouseDetails
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..HouseDetails
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..HouseDetails
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..HouseDetails
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..HouseDetails

--Dropping Column SalesDateConverted because by mistake created extra Column.
ALTER TABLE PortfolioProject..HouseDetails
DROP Column SalesDateConverted

--Now Breaking OwnerAddressColumn into Address,city and state using parsename.

SELECT OwnerAddress
FROM PortfolioProject..HouseDetails

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..HouseDetails

--Now creating Column to store all these valuse by using Update.

ALTER TABLE PortfolioProject..HouseDetails
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..HouseDetails
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..HouseDetails
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..HouseDetails
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..HouseDetails
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..HouseDetails
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..HouseDetails

--Change Y and N to Yes and No in 'Sold as Vacant' Field.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..HouseDetails
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..HouseDetails

UPDATE PortfolioProject..HouseDetails
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num

From PortfolioProject..HouseDetails

)
SELECT *
From RowNumCTE
Where row_num > 1

DELETE
From RowNumCTE
Where row_num > 1


--DELETE UNUSED COLUMNS

Select *
From PortfolioProject..HouseDetails


ALTER TABLE PortfolioProject..HouseDetails
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

