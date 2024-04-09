SELECT * 
FROM PortfoliaProject..NashvilleHousing

--standardize date format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfoliaProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

--populate property address data
SELECT PropertyAddress
FROM PortfoliaProject..NashvilleHousing
WHERE PropertyAddress is null

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfoliaProject..NashvilleHousing a
JOIN PortfoliaProject..NashvilleHousing b
   ON a.ParcelID=b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfoliaProject..NashvilleHousing a
JOIN PortfoliaProject..NashvilleHousing b
   ON a.ParcelID=b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is  null

--Breaking out address into individual columns(address,city,state)
--SELECT 
--SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) AS Address
--FROM PortfoliaProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortfoliaProject..NashvilleHousing


ALTER TABLE PortfoliaProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update PortfoliaProject..NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE PortfoliaProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255)
Update PortfoliaProject..NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--ParseName
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
parsename(REPLACE(OwnerAddress,',','.'),3)
FROM PortfoliaProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
parsename(REPLACE(OwnerAddress,',','.'),1)
FROM PortfoliaProject..NashvilleHousing


ALTER TABLE PortfoliaProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update PortfoliaProject..NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE PortfoliaProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update PortfoliaProject..NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfoliaProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update PortfoliaProject..NashvilleHousing
SET OwnerSplitState=parsename(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and NO in 'Sold as vacant' field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfoliaProject..NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant,
 CASE
   WHEN SoldAsVacant='Y' THEN 'YES'
   WHEN SoldAsVacant='N' THEN 'NO'
   ELSE SoldAsVacant
 END
FROM PortfoliaProject..NashvilleHousing

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					LegalReference
					ORDER BY
					    UniqueID
						) AS row_num
FROM PortfoliaProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Delet unused columns

SELECT *
FROM PortfoliaProject..NashvilleHousing
ALTER TABLE PortfoliaProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

	                      