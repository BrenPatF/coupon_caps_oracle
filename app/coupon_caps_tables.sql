DROP TABLE IF EXISTS coupon_cap_mapping
/
DROP TABLE IF EXISTS coupon_data
/
DROP TABLE IF EXISTS cap_data
/
PROMPT Create coupon_data
CREATE TABLE coupon_data ( 
	coupon 			VARCHAR2(10),
	value 			INTEGER,
	CONSTRAINT cou_pk PRIMARY KEY (coupon))
/
INSERT INTO coupon_data 
WITH data ( coupon, value ) AS ( 
	SELECT 'A', 100 FROM DUAL UNION ALL 
	SELECT 'B', 40  FROM DUAL UNION ALL 
	SELECT 'C', 120 FROM DUAL UNION ALL 
	SELECT 'D', 10  FROM DUAL UNION ALL 
	SELECT 'E', 200 FROM DUAL  
)
SELECT * FROM data
/
SELECT * FROM coupon_data
/
PROMPT Create cap_data
CREATE TABLE cap_data (
	cap_name 		VARCHAR2(10), 
	cap_limit 		INTEGER,
	CONSTRAINT cap_pk PRIMARY KEY (cap_name))
/
INSERT INTO cap_data 
WITH data  ( cap_name, cap_limit ) AS ( 
	SELECT 'Cap 1', 150 FROM DUAL UNION ALL 
	SELECT 'Cap 2', 70  FROM DUAL  
)
SELECT * FROM data
/
SELECT * FROM cap_data
/
CREATE TABLE coupon_cap_mapping ( 
	coupon 			VARCHAR2(10), 
	cap_name 		VARCHAR2(10),
	cap_sequence  	INTEGER,
	CONSTRAINT ccm_pk PRIMARY KEY (coupon, cap_sequence))
/
INSERT INTO coupon_cap_mapping 
WITH data  ( coupon, cap_name, cap_sequence ) AS ( 
	SELECT 'A', 'Cap 1', 1 FROM DUAL UNION ALL 
	SELECT 'A', 'Cap 2', 2 FROM DUAL UNION ALL 
	SELECT 'B', 'Cap 2', 1 FROM DUAL UNION ALL 
	SELECT 'C', 'Cap 2', 1 FROM DUAL UNION ALL 
	SELECT 'C', 'Cap 1', 2 FROM DUAL UNION ALL 
	SELECT 'D', 'Cap 1', 1 FROM DUAL UNION ALL 
	SELECT 'E', 'Cap 1', 1 FROM DUAL UNION ALL 
	SELECT 'E', 'Cap 2', 2 FROM DUAL  
)
SELECT * FROM data
/
PROMPT Create coupon_cap_mapping
SELECT * FROM coupon_cap_mapping
/