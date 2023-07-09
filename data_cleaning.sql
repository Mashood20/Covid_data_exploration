SELECT *
FROM Data_cleaning.dbo.Nashville_housing_data

--changing date format

SELECT convert(date, SaleDate)
FROM Data_cleaning.dbo.Nashville_housing_data

UPDATE Nashville_housing_data
SET SaleDate = CONVERT(date, SaleDate)

--populate property address data

SELECT a.parcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_cleaning.dbo.Nashville_housing_data a 
JOIN Data_cleaning.dbo.Nashville_housing_data b 
    ON a.parcelID = b.parcelID
    And a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

-- updating it 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_cleaning.dbo.Nashville_housing_data a 
JOIN Data_cleaning.dbo.Nashville_housing_data b 
    ON a.parcelID = b.parcelID
    And a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL


--Breaking Out address into individual columns(address, City, state)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) ) as Address
FROM Data_cleaning.dbo.Nashville_housing_data

Alter TABLE Nashville_housing_data
Add FirstLineOfAddress NVARCHAR(255);

UPDATE Nashville_housing_data
SET FirstLineOfAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter TABLE Nashville_housing_data
Add City NVARCHAR(255);

UPDATE Nashville_housing_data
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- split owners address with different method

SELECT OwnerAddress
FROM Data_cleaning.dbo.Nashville_housing_data

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as ,
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Data_cleaning.dbo.Nashville_housing_data

Alter TABLE Nashville_housing_data
Add ownersplitaddress NVARCHAR(255);

UPDATE Nashville_housing_data
SET ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter TABLE Nashville_housing_data
Add ownersplitcity NVARCHAR(255);

UPDATE Nashville_housing_data
SET ownersplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter TABLE Nashville_housing_data
Add ownersplitstate NVARCHAR(255);

UPDATE Nashville_housing_data
SET ownersplitstate= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "sold as vacant"

SELECT SoldAsVacant, 
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant
     END
FROM Data_cleaning.dbo.Nashville_housing_data


UPDATE Nashville_housing_data
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant
     END

-- checking if it worked
SELECT Distinct(SoldAsVacant), Count(soldAsVacant)
FROM Data_cleaning.dbo.Nashville_housing_data
GROUP by SoldAsVacant
ORDER by 2


--remove duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     Order BY
                        UniqueID 
    ) row_num
FROM Data_cleaning.dbo.Nashville_housing_data
)

DELETE
FROM RowNumCTE 
WHERE row_num > 1

--Delete Unused Columns
select *
FROM Data_cleaning.dbo.Nashville_housing_data

ALTER TABLE Data_cleaning.dbo.Nashville_housing_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE Data_cleaning.dbo.Nashville_housing_data
DROP COLUMN Saledate;