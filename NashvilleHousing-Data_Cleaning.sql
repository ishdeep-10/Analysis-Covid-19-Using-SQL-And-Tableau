-- Data Cleaning Using SQL

select * from [Portfolio-Project].dbo.NashvilleHousing

-- Standardize Sale Date
select SaleDateConverted , CONVERT(Date,SaleDate)
from [Portfolio-Project].dbo.NashvilleHousing

update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data
select * 
from [Portfolio-Project].dbo.NashvilleHousing
order by ParcelID

-- we see that every parcelID has the same property address. Thus for null values of propert address we can subsitute it with seeing other values of the address with the same parcelID
select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress)
from [Portfolio-Project].dbo.NashvilleHousing a
join [Portfolio-Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
from [Portfolio-Project].dbo.NashvilleHousing a
join [Portfolio-Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking Address into three columns (Address , City , State)

select 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress)) as City
from [Portfolio-Project].dbo.NashvilleHousing

alter table [Portfolio-Project].dbo.NashvilleHousing
add PropertyAddressSplit Nvarchar(255);

update [Portfolio-Project].dbo.NashvilleHousing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1)

alter table [Portfolio-Project].dbo.NashvilleHousing
add PropertyAddressCity Nvarchar(255);

update [Portfolio-Project].dbo.NashvilleHousing
Set PropertyAddressCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress))

alter table [Portfolio-Project].dbo.NashvilleHousing drop column PropertySplitAddress;

select OwnerAddress from [Portfolio-Project].dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from [Portfolio-Project].dbo.NashvilleHousing


alter table [Portfolio-Project].dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update [Portfolio-Project].dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table [Portfolio-Project].dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update [Portfolio-Project].dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table [Portfolio-Project].dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

update [Portfolio-Project].dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * from [Portfolio-Project].dbo.NashvilleHousing


-- Changing Y and N to Yes and No for SoldVacant column

select distinct(SoldAsVacant) , count(SoldAsVacant)
from [Portfolio-Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
from [Portfolio-Project].dbo.NashvilleHousing

update [Portfolio-Project].dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates

WITH ROWNUMCTE AS(
select * , 
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,LegalReference
				 order by 
					UniqueID
					) row_num
from [Portfolio-Project].dbo.NashvilleHousing
--order by ParcelID
)

select *
FROM  ROWNUMCTE
where row_num>1
order by PropertyAddress

-- Delete Unused Columns

alter table [Portfolio-Project].dbo.NashvilleHousing
drop column OwnerAddress , TaxDistrict , PropertyAddress

select * from [Portfolio-Project].dbo.NashvilleHousing

alter table [Portfolio-Project].dbo.NashvilleHousing
drop column SaleDate






