-- ============================================================
-- Pergunta de negócio 02
-- Requerente: Diretoria/Executivo
-- Pergunta: A receita está crescendo ou caindo mês a mês?

-- Decisões de recorte aplicadas:
-- - Período: 2017-01 a 2018-08
-- - Pedidos com order_status = 'canceled' não contam como receita
-- (ver query 1 pra justificativa desse recorte)

-- Receita é a soma do preço dos itens do pedido, sem frete
-- (ver query 1 pra justificativa dessa definição)
-- ============================================================


WITH receita_mensal AS(
	SELECT
		DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
		SUM(oi.price) AS receita
	FROM order_items oi
	JOIN orders o 
		ON oi.order_id = o.order_id 
	WHERE o.order_status != 'canceled' AND
		o.order_purchase_timestamp >= '2017-01-01' AND 
		o.order_purchase_timestamp < '2018-09-01'
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


-- Entre janeiro e novembro de 2017 houve um predominante aumento na receita mês a mês
-- Em dezembro de 2017 houve uma queda expressiva de 26,1% em relação ao mês anterior, o que é incomum para um mês de festividades
-- Após isso, o crescimento estagnou em relação aos meses anteriores, até agosto de 2018. 


-- ========= Aprendizados com essa consulta =========
-- Uso de DATE_TRUNC() para agrupar as datas dos pedidos em um mesmo dia e mês, e assim poder calcular a receita mensal.

-- Uso da window function LAG() para acessar a receita de linhas anteriores e poder calcular a porcentagem de crescimento ao longo dos meses.

-- Uso de NULLIF no cálculo da taxa de crescimento para evitar divisões por 0.