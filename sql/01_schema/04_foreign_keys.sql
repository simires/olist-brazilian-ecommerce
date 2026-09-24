-- ============================================================
-- Aplicado DEPOIS da carga dos dados e da limpeza dos dados
-- (ver 03_data_cleaning.sql para os ajustes que precisaram 
-- ser feitos antes destas FKs passarem sem erro de violação).
-- ============================================================

-- ========= Inserir chaves estrangeiras =========

ALTER TABLE orders ADD CONSTRAINT fk_orders_customers
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_payments ADD CONSTRAINT fk_payments_orders
	FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_reviews ADD CONSTRAINT fk_reviews_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items ADD CONSTRAINT fk_items_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items ADD CONSTRAINT fk_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE order_items ADD CONSTRAINT fk_items_seller
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

ALTER TABLE products ADD CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name);

-- Nota de design: customer_zip_code_prefix e seller_zip_code_prefix NÃO têm FK para geolocation.geolocation_zip_code_prefix.
-- Motivo: geolocation não cobre 100% dos prefixos de CEP presentes em customers/sellers, então travar a FK quebraria a importação.
-- A ligação existe apenas como referência para JOIN (com o índice idx_geolocation_zip criado em 01_create_tables.sql para performance).

-- Query de verificação: lista todas as FKs ativas no banco
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS tabela_referenciada,
    ccu.column_name AS coluna_referenciada
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';