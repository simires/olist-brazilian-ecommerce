-- ============================================================
-- Validação: a ausência de review introduz viés na comparação de
-- nota média entre pedidos atrasados e no prazo (query 03)?
--
-- Motivação: a query 03 inclui pedidos sem avaliação na contagem
-- de total_pedidos/pct_atraso, mas os exclui do cálculo 
-- de nota_media_regiao (AVG ignora NULL).
-- Isso só é seguro se a taxa de resposta à pesquisa for parecida
-- entre os dois grupos, caso contrário, a nota média comparada
-- estaria representando perfis de cliente diferentes em cada grupo,
-- não só a experiência de atraso em si.
-- ============================================================


WITH nota_por_pedido AS (
    SELECT order_id, AVG(review_score) AS nota_media
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'Atrasado' ELSE 'No prazo' END AS situacao,
    COUNT(*) AS total_pedidos,
    COUNT(np.nota_media) AS pedidos_com_review,
    ROUND(100.0 * COUNT(np.nota_media) / COUNT(*), 1) AS pct_com_review,
    ROUND(AVG(np.nota_media), 2) AS nota_media
FROM vw_stg_orders_validos o
LEFT JOIN nota_por_pedido np ON o.order_id = np.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY situacao;


-- ============================================================
-- Achado: independente de o pedido estar atrasado ou no prazo, a
-- taxa de resposta à pesquisa (pct_com_review) é parecida entre os
-- dois grupos (a nota de review não está enviesada por diferença
-- relevante de taxa de resposta entre eles).
--
-- Decisão confirmada: a comparação de nota_media_regiao entre
-- atrasados e no prazo na query 03 é válida. Pedidos sem review
-- podem continuar inclusos via LEFT JOIN sem ressalva adicional.
-- ============================================================