----------------------------------------------------------------------------
# ERROR CODE 1175 발생 시,
SET SQL_SAFE_UPDATES = 0;

# 해주고 원하는 SQL 구문 쓴 뒤, 다시
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM portfolio_house.nashville_housing

----------------------------------------------------------------------------
-- Populate Property Data

SELECT PropertyAddress
FROM portfolio_house.nashville_housing

SELECT *
FROM portfolio_house.nashville_housing
-- WHERE PropertyAddress = ''


-- MYSQL에서는 IFNULL이 ISNULL & null과 빈문자열은 다름
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
		IF(a.PropertyAddress, '', b.PropertyAddress)
FROM portfolio_house.nashville_housing a
JOIN portfolio_house.nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = ''


-- join하여 빈 주소 업데이트
UPDATE portfolio_house.nashville_housing a 
INNER JOIN portfolio_house.nashville_housing b
ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IF(a.PropertyAddress, '', b.PropertyAddress)
WHERE a.PropertyAddress = ''


----------------------------------------------------------------------------
-- Breaking out Adress into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM portfolio_house.nashville_housing
-- WHERE PropertyAddress = ''
-- ORDER BY ParcelID


-- INSTR = 좌측에서 몇 번째에 해당 문자가 있는지 알려주는 함수 // INSTR(원본, 찾을 문자)
-- substring(원본문자열, 시작 위치값, 가져올 길이 값)
-- -1을 해서 쉼표 앞까지 받아오기
SELECT  
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address
, SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) AS City
FROM portfolio_house.nashville_housing

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1)

ALTER TABLE nashville_housing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress))


-- SUBSTRING_INDEX(문자열, 구분자, 구분자 Index)
-- Split 처럼 문자열 추출 : SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(문자열, 구분자, 구분자 Index), 구분자, -1)
SELECT OwnerAddress
FROM portfolio_house.nashville_housing

SELECT
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1) AS Address
, SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City
, SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS State
FROM portfolio_house.nashville_housing

ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1)

ALTER TABLE nashville_housing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)

ALTER TABLE nashville_housing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)


----------------------------------------------------------------------------
-- Change Y and N to Yes and NO in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio_house.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM portfolio_house.nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
    END
FROM portfolio_house.nashville_housing  # 이 줄은 제외하고 실행

---------------------------------------------------------------------------
-- Delete unused Columns  # make it more usable

SELECT *
FROM portfolio_house.nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;

ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict;

ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress;

---------------------------------------------------------------------------

