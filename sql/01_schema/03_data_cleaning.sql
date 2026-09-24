-- ============================================================
-- Ajustes de qualidade de dado aplicados após a importação dos
-- CSVs e ANTES de rodar 03_foreign_keys.sql.
-- ============================================================

-- ------------------------------------------------------------
-- 1) String vazia ('') importada como valor em vez de NULL em products.product_category_name
--    (COUNT(product_category_name) batia diferente do Python, que
--    contava corretamente os nulos usando .notna())
-- ------------------------------------------------------------

-- Verificando a quantidade de dados não nulos e strings vazias que tem na coluna:
SELECT
    COUNT(*) AS total,
    COUNT(product_category_name) AS nao_nulo,
    SUM(CASE WHEN product_category_name = '' THEN 1 ELSE 0 END) AS string_vazia,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_de_verdade
FROM public.products;

-- Convertendo strings vazias em nulos de verdade:
UPDATE public.products
SET product_category_name = NULL
WHERE product_category_name = '';

-- ------------------------------------------------------------
-- 2) Categorias de produto sem tradução correspondente
--    (achado via LEFT JOIN antes de aplicar fk_products_category)
-- ------------------------------------------------------------

-- Query de diagnóstico (rodar antes de aplicar a FK em products):
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- Há categorias de produtos na tabela products que não existem na tabela de tradução dos nomes das categorias.
-- Neste caso, as categorias faltantes são: portateis_cozinha_e_preparadores_de_alimentos e pc_gamer.
-- Inserindo as categorias faltantes na tabela de tradução:

INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers');

INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer');
