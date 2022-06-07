SELECT * from Portfolio.dbo.Sheet1$

SELECT SaleDate, CONVERT(Date,SaleDate) as SaleDate1
FROM Portfolio.dbo.Sheet1$



--Clean SaleDate to remove HH:MM:SS

ALTER TABLE Sheet1$
ADD SaleDateConverted Date

UPDATE Sheet1$
SET SaleDateConverted = CONVERT(Date, SaleDate)



--Update NULL duplicate values for Property

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM Portfolio.dbo.Sheet1$ a
JOIN Portfolio.dbo.Sheet1$ b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.Sheet1$ a
JOIN Portfolio.dbo.Sheet1$ b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Clean Property Address

SELECT PropertyAddress
FROM Portfolio.dbo.Sheet1$

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Portfolio.dbo.Sheet1$

ALTER TABLE Portfolio.dbo.Sheet1$
ADD AddressSplit Nvarchar(255)

ALTER TABLE Portfolio.dbo.Sheet1$
ADD CitySplit Nvarchar(255)

UPDATE Portfolio.dbo.Sheet1$
SET AddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE Portfolio.dbo.Sheet1$
SET CitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



--Clean Owner Address

SELECT OwnerAddress from Portfolio.dbo.Sheet1$

SELECT
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio.dbo.Sheet1$

ALTER TABLE Portfolio.dbo.Sheet1$
ADD OwnerAddressState nvarchar(255)

ALTER TABLE Portfolio.dbo.Sheet1$
ADD OwnerAddressCity nvarchar(255)

ALTER TABLE Portfolio.dbo.Sheet1$
ADD OwnerAddressSplit nvarchar(255)

SELECT * FROM Portfolio.dbo.Sheet1$

UPDATE Portfolio.dbo.Sheet1$
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

UPDATE Portfolio.dbo.Sheet1$
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE Portfolio.dbo.Sheet1$
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


--Remove Unnecessary Duplicates for Sales

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from Portfolio.dbo.Sheet1$
GROUP BY SoldAsVacant

UPDATE Portfolio.dbo.Sheet1$
SET SoldAsVacant =
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio.dbo.Sheet1$

WITH temptab AS(
SELECT *,
ROW_NUMBER() OVER(Partition by
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM Portfolio.dbo.Sheet1$
)

SELECT *
FROM temptab
where row_num > 1



--Remove Unused Columns

ALTER TABLE Portfolio.dbo.Sheet1$
DROP COLUMN OwnerAddress,PropertyAddress,SaleDate