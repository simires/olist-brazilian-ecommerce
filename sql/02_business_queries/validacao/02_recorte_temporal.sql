-- ============================================================
-- Validação: qual recorte temporal usar nas análises, para evitar
-- ruído de lançamento da plataforma (início) e coleta incompleta de
-- dados (final)?
--
-- Motivação: ao calcular o crescimento mês a mês (query 02), foram
-- observadas variações percentuais explosivas nos primeiros meses do
-- dataset. Investigação preliminar apontou que os primeiros meses de
-- 2016 são uma anomalia conhecida do dataset Olist (poucos pedidos,
-- fase de lançamento da plataforma).
-- ============================================================
 

SELECT
    TO_CHAR(DATE_TRUNC('month', order_purchase_timestamp), 'YYYY-MM') AS mes,
    COUNT(*) AS total_pedidos
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY mes;


-- ============================================================
-- Achado:
-- - Set a dez/2016: volume anormalmente baixo de pedidos (fase de
--   lançamento da plataforma, não representativo de operação madura).
-- - A partir de set/2018: queda abrupta no volume de pedidos,
--   indicando coleta de dados incompleta nesse período.
--
-- Decisão aplicada: recorte temporal de 2017-01-01 (inclusive) até
-- 2018-09-01 (exclusive). Esta regra está materializada na view
-- vw_stg_orders_validos — qualquer query de negócio que usar essa
-- view já está em conformidade automaticamente, sem necessidade de
-- repetir o filtro manualmente.
-- ============================================================
