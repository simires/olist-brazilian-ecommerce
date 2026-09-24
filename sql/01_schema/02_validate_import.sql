-- ============================================================
-- Rodar logo após importar todos os CSVs (antes de qualquer
-- ajuste de qualidade de dado), para confirmar que a quantidade
-- de linhas de cada tabela bate com o dataset original do Kaggle.

-- Se necessário, use Python para conferir a quantidade de dados 
-- de cada coluna e comparar com os resultados das consultas. 
-- ============================================================

SELECT 
	count(product_category_name) AS product_category_name,
	count(product_category_name_english) AS product_category_name_english
FROM product_category_name_translation;

SELECT 
	count(customer_id) AS customer_id,
	count(customer_unique_id) AS customer_unique_id,
	count(customer_zip_code_prefix) AS customer_zip_code_prefix,
	count(customer_city) AS customer_city,
	count(customer_state) AS customer_state
FROM customers;

SELECT 
	count(geolocation_id) AS geolocation_id,
	count(geolocation_zip_code_prefix) AS geolocation_zip_code_prefix,
	count(geolocation_lat) AS geolocation_lat,
	count(geolocation_lng) AS geolocation_lng,
	count(geolocation_city) AS geolocation_city,
	count(geolocation_state) AS geolocation_state
FROM geolocation;


SELECT
	count(product_id) AS product_id,
	count(product_category_name) AS product_category_name,	-- Suas strings vazias não foram convertidas para NULL, pois o tipo de dado VARCHAR aceita strings vazias como dados válidos
	count(product_name_lenght) AS product_name_lenght,
	count(product_description_lenght) AS product_description_lenght,
	count(product_photos_qty) AS product_photos_qty,
	count(product_weight_g) AS product_weight_g,
	count(product_length_cm) AS product_length_cm,
	count(product_height_cm) AS product_height_cm,
	count(product_width_cm) AS product_width_cm
FROM products;

SELECT
	count(order_id) AS order_id,
	count(customer_id) AS customer_id,
	count(order_status) AS order_status,
	count(order_purchase_timestamp) AS order_purchase_timestamp,
	count(order_approved_at) AS order_approved_at,
	count(order_delivered_carrier_date) AS order_delivered_carrier_date,
	count(order_delivered_customer_date) AS order_delivered_customer_date,
	count(order_estimated_delivery_date) AS order_estimated_delivery_date
FROM orders;

SELECT 
	count(order_id) AS order_id,
	count(order_item_id) AS order_item_id,
	count(product_id) AS product_id,
	count(seller_id) AS seller_id,
	count(shipping_limit_date) AS shipping_limit_date,
	count(price) AS price,
	count(freight_value) AS freight_value
FROM order_items;

SELECT 
	count(order_id) AS order_id,
	count(payment_sequential) AS payment_sequential,
	count(payment_type) AS payment_type,
	count(payment_installments) AS payment_installments,
	count(payment_value) AS payment_value
FROM order_payments;

SELECT 
	count(review_pk) AS review_pk,
	count(review_id) AS review_id,
	count(order_id) AS order_id,
	count(review_score) AS review_score,
	count(review_comment_title) AS review_comment_title,
	count(review_comment_message) AS review_comment_message,
	count(review_creation_date) AS review_creation_date,
	count(review_answer_timestamp) AS review_answer_timestamp
FROM order_reviews;

