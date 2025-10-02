/*

cleaning data in SQL queries

*/

select *
from [Portfolio Project].dbo.NashvilleHousing

--standarize date format

select SalesDateConverted, convert(Date, SaleDate)
from [Portfolio Project].dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
Add SalesDateConverted Date;

update NashvilleHousing
SET SalesDateConverted = convert(Date, SaleDate)

--populate property address data

select *
from [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
     and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
     and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into indivual columns (address, city, state)

select PropertyAddress
from [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

from [Portfolio Project].dbo.NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

select *
from [Portfolio Project].dbo.NashvilleHousing


select OwnerAddress
from [Portfolio Project].dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from [Portfolio Project].dbo.NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *
from [Portfolio Project].dbo.NashvilleHousing

-- change y and n to yes and no in "sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
from [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END

-- remove duplicates

WITH RowNumCTE AS(
select *,
ROW_NUMBER() Over(
PARTITION BY ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY
                UniqueID
                ) row_num

from [Portfolio Project].dbo.NashvilleHousing
--ORDER BY ParcelID
)

Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- delete unused columns

select *
from [Portfolio Project].dbo.NashvilleHousing

Alter Table [Portfolio Project].dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [Portfolio Project].dbo.NashvilleHousing
DROP Column SaleDate