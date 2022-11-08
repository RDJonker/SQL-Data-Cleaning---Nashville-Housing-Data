
  -- Cleaning Data in SQL Queries

  Select * 
  From [Portfolio Project]..NashvilleHousing

  ---------------------------------------------------------------------------------------------------------------------------

  --Standardize Date Format

  Select SaleDateConverted , CONVERT(Date, SaleDate)
  From [Portfolio Project]..NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = CONVERT(Date, SaleDate)

  ALTER Table Nashvillehousing
  ADD SaleDateConverted Date;

  Update NashvilleHousing
  SET SaleDateConverted = CONVERT(Date, SaleDate)

  ---------------------------------------------------------------------------------------------------------------------------

  --Populate Property Address data

  Select *
  From [Portfolio Project]..NashvilleHousing
  --WHERE PropertyAddress is null
  Order by ParcelID

  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  From [Portfolio Project]..NashvilleHousing a
  JOIN [Portfolio Project]..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is null

  UPDATE a
  SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  From [Portfolio Project]..NashvilleHousing a
  JOIN [Portfolio Project]..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is null


  ---------------------------------------------------------------------------------------------------------------------------

  --Breaking out Address into individual columns (Addres, City, State)

  --PropertyAddress

  Select PropertyAddress
  From [Portfolio Project]..NashvilleHousing

  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City  
  From [Portfolio Project]..NashvilleHousing

  ALTER Table Nashvillehousing
  ADD PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER Table Nashvillehousing
  ADD PropertySplitCity Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

  --OwnerAddress

  Select OwnerAddress
  From [Portfolio Project]..NashvilleHousing

  SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  From [Portfolio Project]..NashvilleHousing

  ALTER Table Nashvillehousing
  ADD OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

  ALTER Table Nashvillehousing
  ADD OwnerSplitCity Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

  ALTER Table Nashvillehousing
  ADD OwnerSplitState Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


  ---------------------------------------------------------------------------------------------------------------------------

  --Change Y/N to Yes/No in "Sold as Vacant" field


  SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
  From [Portfolio Project]..NashvilleHousing

  UPDATE NashvilleHousing
  SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                          WHEN SoldAsVacant = 'N' THEN 'No'
	                      ELSE SoldAsVacant
	                      END

  SELECT DISTINCT(SoldAsVacant)
  FROM [Portfolio Project]..NashvilleHousing
  
  ---------------------------------------------------------------------------------------------------------------------------

  --Remove Duplicates

  WITH RowNumCTE AS(
  SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			   UniqueID
			   ) row_num
  FROM [Portfolio Project]..NashvilleHousing
  )

  DELETE 
  FROM RowNumCTE
  WHERE row_num > 1


  ---------------------------------------------------------------------------------------------------------------------------

  --Delete unused columns

  ALTER Table [Portfolio Project]..NashvilleHousing
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

  ALTER Table [Portfolio Project]..NashvilleHousing
  DROP COLUMN SaleDate

  SELECT *
  FROM [Portfolio Project]..NashvilleHousing

  ---------------------------------------------------------------------------------------------------------------------------