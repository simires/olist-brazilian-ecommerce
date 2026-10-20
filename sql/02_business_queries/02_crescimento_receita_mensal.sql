-- ============================================================
-- Pergunta de negócio 02
-- Requerente: Diretoria/Executivo
-- Pergunta: A receita está crescendo ou caindo mês a mês?

-- Decisões de recorte aplicadas:
-- - Recorte temporal: aplicado via vw_stg_orders_validos
--   (ver validacao/02_recorte_temporal.sql)
--   (a query atual foi a origem da investigação) 
-- - Pedidos com order_status = 'canceled' não contam como receita

-- Receita é a soma do preço dos itens do pedido, sem frete
-- (freight_value é custo de transporte, não faturamento de produto)
-- ============================================================


WITH receita_mensal AS(
	SELECT
		DATE_TRUNC('month', vsov.order_purchase_timestamp) AS mes,
		SUM(oi.price) AS receita
	FROM order_items oi
	JOIN vw_stg_orders_validos vsov  
		ON oi.order_id = vsov.order_id 
	WHERE vsov.order_status != 'canceled'
	GROUP BY mes
)
SELECT 
	TO_CHAR(mes, 'YYYY-MM') AS mes,
	receita,
	LAG(receita) OVER (ORDER BY mes) AS receita_mes_anterior,
	ROUND(
		100.0 * (receita - (LAG(receita) OVER (ORDER BY mes)))
		/ NULLIF (LAG(receita) OVER (ORDER BY mes), 0),
		1
	) AS variacao_pct
FROM receita_mensal
ORDER BY mes;


-- ===================== Achados =====================
-- Entre janeiro e novembro de 2017 houve um predominante aumento na receita mês a mês
-- Em dezembro de 2017 houve uma queda expressiva de 26,1% em relação ao mês anterior, o que é incomum para um mês de festividades
-- Após isso, o crescimento estagnou em relação aos meses anteriores, até agosto de 2018. 


-- ========= Aprendizados com essa consulta =========
-- Uso de DATE_TRUNC() para agrupar as datas dos pedidos em um mesmo dia e mês, e assim poder calcular a receita mensal.
--
-- Uso da window function LAG() para acessar a receita de linhas anteriores e poder calcular a porcentagem de crescimento ao longo dos meses.
--
-- Uso de NULLIF no cálculo da taxa de crescimento para evitar divisões por 0.