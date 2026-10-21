-- ============================================================
-- Pergunta de negócio 03
-- Requerente: Logística
-- Pergunta: o prazo de entrega prometido está sendo cumprido?
-- Existe alguma região onde atrasamos sistematicamente, 
-- e isso está custando nota do cliente?

-- Decisões de recorte aplicadas:
-- - Recorte temporal: aplicado via vw_stg_orders_validos
--   (ver validacao/02_recorte_temporal.sql)
-- - Pedidos ainda não entregues (NULL) são excluídos, pois não 
--   podem ser comparados com a data estimada de entrega

-- nota_por_pedido (CTE): order_reviews pode ter mais de uma linha por
-- order_id (review_id duplicado é uma anomalia conhecida do
-- dataset). Pré-agregar para uma linha por pedido evita contar o
-- mesmo pedido mais de uma vez na agregação por região.

-- Pedidos sem review (LEFT JOIN com nota_por_pedido) são inclusos
-- na contagem de atrasos (pois é uma métrica de entrega, não
-- depende de review), mas não entram na nota média por região (AVG
-- ignora NULL automaticamente). Checagem de que essa ausência não
-- distorce a comparação entre grupos:
-- validacao/03_propensao_responder_review.sql
-- ============================================================


WITH nota_por_pedido AS (
    SELECT 
    	order_id, 
    	AVG(review_score) AS nota_media		-- Um mesmo pedido pode ter mais de uma review, por isso resumimos a nota dada.
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    c.customer_state AS estado,
    COUNT(*) AS total_pedidos,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS pedidos_atrasados,
    ROUND(
        100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        / COUNT(*), 
        1
    ) AS pct_atraso,
    ROUND(AVG(np.nota_media), 2) AS nota_media_regiao
FROM vw_stg_orders_validos o
JOIN customers c
	ON o.customer_id = c.customer_id
LEFT JOIN nota_por_pedido np				-- Pedidos que não foram avaliados também são inclusos com o LEFT JOIN.
	ON o.order_id = np.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY pct_atraso DESC;


-- ===================== Achados =====================
-- Existe uma relação clara entre atraso na entrega e satisfação do cliente: estados com maior  
-- percentual de pedidos atrasados sistematicamente registram nota média mais baixa. O problema 
-- está concentrado principalmente no Nordeste (Alagoas e Maranhão lideram o atraso, acima de 19%),  
-- mas o achado mais acionável está no Sudeste: Rio de Janeiro e Espírito Santo apresentam taxa de 
-- atraso mais que o dobro de São Paulo e Minas Gerais, apesar de serem mercados da mesma região.

-- ========= Aprendizados com essa consulta =========
-- Aplicação prática de CASE WHEN, que foi necessária para verificar se um determinado pedido 
-- estava com entrega atrasada ou não.
