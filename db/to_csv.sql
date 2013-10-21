SELECT 'id', 'region_id', 'name', 'memo', 'created_at', 'updated_at', 'code', 'ref_store_id', 'area', 'location', 'import_id', 'ref_count', 'region_name', 'pinyin'
UNION ALL
SELECT * FROM stores INTO OUTFILE '/tmp/stores.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

SELECT 'name', 'memo', 'created_at', 'updated_at', 'code', 'parent_id', 'import_id', 'pinyin', 'display_name'
UNION ALL
SELECT * FROM categories INTO OUTFILE '/tmp/categories.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

SELECT 'code', 'category_id', 'brand_id', 'mfr_id', 'user_id', 'import_id', 'name', 'height', 'width', 'depth', 'weight', 'price_zone', 'size_name', 'case_pack_name', 'barcode', 'color', 'discard_from', 'discard_by', 'created_at', 'updated_at', 'supplier_id', 'sale_type', 'new_product', 'on_promotion'
UNION ALL
SELECT * FROM products INTO OUTFILE '/tmp/products.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

SELECT 'id', 'product_id', 'store_id', 'num_stores', 'user_id', 'import_id', 'price', 'facing', 'run', 'volume', 'volume_rank', 'value', 'value_rank', 'margin', 'margin_rank', 'psi', 'psi_rank', 'psi_rule_id', 'rcmd_facing', 'job_id', 'detail', 'started_at', 'ended_at', 'created_at', 'updated_at'
UNION ALL
SELECT * FROM sales INTO OUTFILE '/tmp/sales.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';
