/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject.dbo.HousingProject

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.HousingProject


UPDATE HousingProject
SET SaleDate = CONVERT(Date,SaleDate)

Select SaleDate
From PortfolioProject.dbo.HousingProject
-- If it doesn't Update properly

ALTER TABLE HousingProject
Add SaleDateConverted Date;

Update HousingProject
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.HousingProject

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.HousingProject
WHERE PropertyAddress is null

SELECT *
FROM PortfolioProject.dbo.HousingProject
--Where PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM PortfolioProject.dbo.HousingProject a
JOIN PortfolioProject.dbo.HousingProject b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.HousingProject a
JOIN PortfolioProject.dbo.HousingProject b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.HousingProject
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address1
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address2

FROM PortfolioProject.dbo.HousingProject


ALTER TABLE HousingProject
ADD PropertySplitAddress Nvarchar(255);

Update HousingProject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingProject
ADD PropertySplitCity NVARCHAR(255);

Update HousingProject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




SELECT *
FROM PortfolioProject.dbo.HousingProject





SELECT OwnerAddress
FROM PortfolioProject.dbo.HousingProject


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.HousingProject



ALTER TABLE HousingProject
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE HousingProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingProject
ADD OwnerSplitCity NVARCHAR(255);

UPDATE HousingProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE HousingProject
ADD OwnerSplitState NVARCHAR(255);

UPDATE HousingProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
FROM PortfolioProject.dbo.HousingProject




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.HousingProject
GROUP BY SoldAsVacant
ORDER BY 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.HousingProject


Update HousingProject
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.HousingProject
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.HousingProject




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



SELECT *
FROM PortfolioProject.dbo.HousingProject


ALTER TABLE PortfolioProject.dbo.HousingProject
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















