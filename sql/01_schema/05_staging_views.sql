-- ============================================================
-- Views de staging: resolvem problemas técnicos/de qualidade do
-- dado bruto. Não respondem pergunta de negócio nenhuma sozinhas,
-- mas servem de base para as queries de 02_business_queries/.
-- ============================================================

-- ------------------------------------------------------------
-- vw_stg_geolocation
--
-- Problema resolvido: geolocation tem múltiplas linhas de lat/lng
-- por geolocation_zip_code_prefix (por isso a PK da tabela é um
-- surrogate key, não o zip code prefix). Essa view entrega uma
-- coordenada única por prefixo, calculada como centroide (média).
-- ------------------------------------------------------------
CREATE VIEW vw_stg_geolocation AS
SELECT
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS avg_lat,
    AVG(geolocation_lng) AS avg_lng
FROM geolocation
GROUP BY geolocation_zip_code_prefix;


-- ------------------------------------------------------------
-- vw_stg_orders_validos
--
-- Problema resolvido: encapsula o recorte temporal usado 
-- em toda análise de negócio que envolve volume,
-- receita ou tendência ao longo do tempo.
--
-- Regras aplicadas:
-- - order_purchase_timestamp entre 2017-01-01 (inclusive) e
--   2018-09-01 (exclusive)
--
-- Justificativa completa e evidência (gráfico de pedidos por mês):
-- validacao/02_recorte_temporal.sql
--
-- USO: queries de negócio que medem volume/receita/tendência devem
-- consultar esta view em vez de orders diretamente.
--
-- EXCEÇÃO: queries de diagnóstico/validação (como a que originou
-- esta view) devem continuar consultando orders diretamente, sem
-- filtro. Usar esta view ali esconderia a própria anomalia que
-- justificou sua criação.
--
-- MANUTENÇÃO: o limite 2018-09-01 reflete o fim da coleta de dados
-- deste dataset específico (estático, não vai mudar). Se este
-- projeto algum dia for adaptado para um dataset com atualização
-- contínua, essa data fixa precisaria virar um cálculo dinâmico.
-- ------------------------------------------------------------
CREATE VIEW vw_stg_orders_validos AS
SELECT *
FROM orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp < '2018-09-01';
