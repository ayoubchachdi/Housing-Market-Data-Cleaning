select *
from pro..Nashville




--checking data type
EXEC sp_help 'Nashville'

----Standardize Date Format
select *
from Nashville

Alter Table Nashville
Add SaleDateConverted Date

Update Nashville
Set SaleDateConverted = Convert(Date,SaleDate)

-----Populate Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from pro..Nashville a
join pro..Nashville b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from pro..Nashville a
join pro..Nashville b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-----Breaking out Property address into indivuals column (Addrees,City)

select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)- 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) as City
from Nashville

Alter table Nashville
add Address nvarchar(255)

update Nashville
set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)- 1)

Alter table Nashville
add City nvarchar(255)

update Nashville
set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))



-----Breaking out Property address into indivuals column (Addrees,City)


select OwnerAddress, PARSENAME(replace(OwnerAddress, ',', '.'), 1), PARSENAME(replace(OwnerAddress, ',', '.'), 2),  PARSENAME(replace(OwnerAddress, ',', '.'), 3)
from Nashville

Alter table Nashville
add OwnerSplitAddress nvarchar(255)

update Nashville
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter table Nashville
add OwnerSplitCity nvarchar(255)

update Nashville
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter table Nashville
add OwnerSplitstate nvarchar(255)

update Nashville
set OwnerSplitstate = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitstate
from Nashville


----------------Change Y and N to Yes and No in "Sold as vacant"

select distinct(SoldAsVacant), Count(SoldAsVacant)
from Nashville
Group by SoldAsVacant


select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'YES'
     when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end
from Nashville


update Nashville
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'YES'
     when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end

---------------Delete duplicate

With RowNumCTE as (
select *,
ROW_NUMBER() over ( partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID ) rownum
from Nashville  )
select *
from RowNumCTE
where rownum > 1


With RowNumCTE as (
select *,
ROW_NUMBER() over ( partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID ) rownum
from Nashville  )
Delete
from RowNumCTE
where rownum > 1



--------------Delete unused columns

select *
from Nashville

ALTER TABLE Nashville
Drop column PropertyAddress, SaleDate, TaxDistrict, OwnerAddress