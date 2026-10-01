-- ============================================================
-- Pergunta de negócio 01
-- Requerente: Diretoria/Executivo
-- Pergunta: Quais categorias de produto trazem mais receita hoje?

-- Decisões de recorte aplicadas:
-- - Período: 2017-01 a 2018-08 (exclui 2016, pois a operação estava 
--   em fase de lançamento com volume não representativo; 
--   exclui set/out-2018, pois a coleta de dados foi interrompida no meio do mês)
-- - Pedidos com order_status = 'canceled' não contam como receita

-- Receita é a soma do preço dos itens do pedido, sem frete 
-- (freight_value é custo de transporte, não faturamento de produto)
-- ============================================================


SELECT 
	COALESCE(p.product_category_name, 'não informado') AS categoria, 
	COALESCE(pcnt.product_category_name_english, 'não informado') AS categoria_ingles, 
	SUM(oi.price) AS receita
FROM products p 
LEFT JOIN product_category_name_translation pcnt 			-- LEFT JOIN, pois há produtos sem categoria, logo sem tradução.
	ON pcnt.product_category_name = p.product_category_name
JOIN order_items oi 
	ON oi.product_id = p.product_id 
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status != 'canceled' AND
		o.order_purchase_timestamp >= '2017-01-01' AND 
		o.order_purchase_timestamp < '2018-09-01'
GROUP BY 
	p.product_category_name, 
	pcnt.product_category_name_english
ORDER BY receita DESC

-- As três categorias de produto que trazem mais receita atualmente são:
-- Beleza e saúde: R$ 1.251.145,54
-- Relógios e presentes: R$ 1.194.824,97
-- Cama, mesa e banho: R$ 1.035.485,07


-- ========= Aprendizados com essa consulta =========
-- Descobri que deveria usar LEFT JOIN por causa dos 610 produtos que não possuíam categoria na tabela products.
-- Se não usasse LEFT JOIN, a receita gerada por esses produtos seria negligenciada na consulta

-- Além disso, descobri o uso prático da função COALESCE, que foi útil para nomear a categoria de produtos "não informado".