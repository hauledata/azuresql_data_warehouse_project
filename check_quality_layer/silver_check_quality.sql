SELECT TOP 10 * FROM bronze.crm_cust_info

SELECT TOP 10 * FROM bronze.erp_cust_az12

SELECT TOP 1000 * FROM bronze.crm_prd_info

SELECT TOP 1000 * FROM bronze.crm_sales_details

/* crm_cust_info */
-- Check for Duplicates:
SELECT cst_id,
    COUNT(*) AS count_number
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466

-- Check for unwanted Spaces:
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

SELECT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)

--Data Standardization & Consistency
SELECT DISTINCT cst_gndr 
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status 
FROM bronze.crm_cust_info


/* crm_prd_info */
--- Check for duplicates
SELECT prd_id
    ,COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces:
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check for NULL and Negative Number
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost <0 or prd_cost IS NULL

-- Check for data standardization
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- crm_sales_details
--Check for unwanted spaces
SELECT * 
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

--Check the unvalid values
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT DISTINCT cst_id FROM silver.crm_cust_info)

SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT DISTINCT prd_key FROM silver.crm_prd_info)

--Check for Invalid Date
SELECT 
    NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8

SELECT 
    NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8

SELECT 
    NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8

--Check forr business rules
SELECT sls_sales,   sls_price, sls_quantity
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <0 OR sls_quantity <0 OR sls_price <0
--->>> Data Issues will be fixed direct in source system
--->>> Data Issues has to be fixed in DW

---erp_cust_az12
SELECT * FROM bronze.erp_cust_az12
SELECT  * FROM bronze.crm_cust_info

-- Check for unwanted spaces:
SELECT *
FROM bronze.erp_cust_az12
WHERE cid !=TRIM(cid) -->> No problem


-- Extract the customer key
SELECT 
    cid,
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE   CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid 
        END NOT IN (SELECT DISTINCT cst_key FROM bronze.crm_cust_info) -->> All results matching data

-- Check the range values bdate column
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate >  GETDATE()

--Data Standardiztion & Consistency
SELECT DISTINCT
    gen,
    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M',  'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12

/* erp_ loc_a101 */
SELECT *  FROM bronze.crm_cust_info
-- Extract match the customer key
SELECT 
    cid,
    REPLACE(cid,'-','') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid,'-','') NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

--Data Standardiztion & Consistency
SELECT DISTINCT 
    cntry AS old_cntry,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101

/* erp_px_cat_g1v2 */
SELECT * FROM bronze.erp_px_cat_g1v2

--Check for unwanted spaces:
SELECT * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--Data Standardiztion & Consistency
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2


