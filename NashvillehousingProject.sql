
-------------------------- CONVERT SALE DATE FORMAT TO DATE ----------------------------------------------------------------------------------

select saleDate , convert(date,saleDate)
from sheet1$

---- ----------------------converting using ALTER statement ----------------------------------------------------------------------------------------
alter table sheet1$
add SaleDateConverted date

update sheet1$
set SaleDateConverted = convert(date,saleDate)

select SaleDateConverted from sheet1$ s1


------------------------------------------------------------------------------------------------------------------------------------------==========>

---populate property address---------------------------------------------

select a.parcelID,a.propertyAddress,b.parcelID,b.propertyAddress, 
IsNull(a.propertyAddress,b.propertyAddress)
from sheet1$ a
join sheet1$ b on a.parcelID=b.parcelID
and a.uniqueID<>b.uniqueID
where a.PropertyAddress is null

update a 
set propertyAddress=IsNull(a.propertyAddress,b.propertyAddress)
from sheet1$ a
join sheet1$ b on a.parcelID=b.parcelID
and a.uniqueID<>b.uniqueID
where a.PropertyAddress is null

------> breaking out address into individual columns(address, city,state)
select 
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1),
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))
from sheet1$


alter table sheet1$
add propertysplitaddress nvarchar(255)

update sheet1$
set propertysplitaddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table sheet1$
add propertsplitcity nvarchar(255)

update sheet1$
set propertsplitcity = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

------> breaking out owneraddress into individual columns(address, city,state)

select * from sheet1$  

select owneraddress from sheet1$
where owneraddress is not null


--------> using replace stattement ------------------------------------
select 
 PARSENAME(REPLACE(owneraddress,',','.'),3),
 PARSENAME(REPLACE(owneraddress,',','.'),2),
 PARSENAME(REPLACE(owneraddress,',','.'),1)
 from sheet1$ where owneraddress is not null

 alter table sheet1$
 add OwnerSplitaddress nvarchar(255);


 update sheet1$
 set OwnerSplitaddress= PARSENAME(REPLACE(owneraddress,',','.'),3)

 alter table sheet1$
  add OwnerSplitCity nvarchar(255);
  
 update sheet1$
 set OwnerSplitCity= PARSENAME(REPLACE(owneraddress,',','.'),2)

  alter table sheet1$
   add OwnerSplitstate nvarchar(255)

    update sheet1$
 set OwnerSplitstate= PARSENAME(REPLACE(owneraddress,',','.'),1)


  

  ------CHANGE Y AND N TO YES AND NO IN SOLDASVACANT--------------------
  SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT) FROM SHEET1$
  GROUP BY SOLDASVACANT
  ORDER  BY 2

  SELECT SOLDASVACANT 
  , CASE WHEN SOLDASVACANT='Y' THEN 'YES'
         WHEN SOLDASVACANT='N' THEN 'NO'
		 ELSE SOLDASVACANT
         END
 FROM SHEET1$

 UPDATE SHEET1$
 SET SOLDASVACANT=CASE WHEN SOLDASVACANT='Y' THEN 'YES'
         WHEN SOLDASVACANT='N' THEN 'NO'
		 ELSE SOLDASVACANT
         END

---------------------------------------------------------------------------------
--REMOVE DUPLICATES
 WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
PARTITION BY  PARCELID,
PROPERTYADDRESS,
SALEPRICE,SALEDATE,LEGALREFERENCE
ORDER BY UNIQUEID)ROW_NUM
from sheet1$
--ORDER BY PARCELID
)
DELETE FROM RowNumCTE
WHERE ROW_NUM >1
--ORDER BY PROPERTYADDRESS


----------------------------------------------------
--DELETE UNUSED COLUMNS



SELECT * FROM SHEET1$
 
 ALTER  TABLE SHEET1$
 DROP COLUMN OWNERADDRESS,TAXDISTRICT, PROPERTYADDRESS

  ALTER  TABLE SHEET1$
 DROP COLUMN SALEDATE