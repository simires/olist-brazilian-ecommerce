-- ============================================================
-- Criação do schema: tabelas + índice de apoio (sem FKs ainda)
-- ============================================================

-- ========= Tabelas sem dependências =========

CREATE TABLE geolocation (
	geolocation_id SERIAL PRIMARY KEY,	-- chave substituta: zip prefix se repete
	geolocation_zip_code_prefix VARCHAR(5),
	geolocation_lat FLOAT,
	geolocation_lng FLOAT,
	geolocation_city VARCHAR(50),
	geolocation_state CHAR(2)
);
CREATE INDEX idx_geolocation_zip ON geolocation (geolocation_zip_code_prefix);

CREATE TABLE customers (
	customer_id VARCHAR(32) PRIMARY KEY,
	customer_unique_id VARCHAR(32) NOT NULL,
	customer_zip_code_prefix VARCHAR(5),	-- referência a geolocation, sem FK enforced
	customer_city VARCHAR(50),
	customer_state CHAR(2)
);

CREATE TABLE sellers (
	seller_id VARCHAR(32) PRIMARY KEY,
	seller_zip_code_prefix VARCHAR(5),	-- referência a geolocation, sem FK enforced
	seller_city VARCHAR(50),
	seller_state CHAR(2)
);

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(50)
);

-- ========= Tabelas com 1 dependência =========

CREATE TABLE orders (
	order_id VARCHAR(32) PRIMARY KEY,
	customer_id VARCHAR(32) NOT NULL,	-- FK -> customers (um pedido deve estar atrelado a um cliente)
	order_status VARCHAR(50),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,		
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE products (
	product_id VARCHAR(32) PRIMARY KEY,
	product_category_name VARCHAR(50),	-- FK -> product_category_name_translation (nullable: nem todo produto tem categoria)
	product_name_lenght INT,
	product_description_lenght INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

-- ========= Tabelas dependentes de orders =========

CREATE TABLE order_payments (
	order_id VARCHAR(32) NOT NULL,	-- FK -> orders (um pagamento deve estar associado a um pedido)
	payment_sequential INT NOT NULL,
	payment_type VARCHAR(50),
	payment_installments INT,
	payment_value NUMERIC(10, 2),
	PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
	review_pk SERIAL PRIMARY KEY,	-- chave substituta: review_id pode repetir
	review_id VARCHAR(32) NOT NULL,
	order_id VARCHAR(32) NOT NULL,	-- FK -> orders (uma review deve estar associada a um pedido)
	review_score INT CHECK (review_score BETWEEN 1 AND 5),
	review_comment_title TEXT,
	review_comment_message TEXT,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
);

CREATE TABLE order_items (
	order_id VARCHAR(32) NOT NULL,		-- FK -> orders
	order_item_id INT NOT NULL,
	product_id VARCHAR(100) NOT NULL,	-- FK -> products (deve haver o id do produto obrigatoriamente)
	seller_id VARCHAR(100) NOT NULL,	-- FK -> sellers (deve haver um vendedor obrigatoriamente)
	shipping_limit_date TIMESTAMP,
	price NUMERIC(10, 2),
	freight_value NUMERIC(10, 2),
	PRIMARY KEY (order_id, order_item_id)
);
