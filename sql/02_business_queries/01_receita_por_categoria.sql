-- ============================================================
-- Pergunta de negócio 01
-- Requerente: Diretoria/Executivo
-- Pergunta: Quais categorias de produto trazem mais receita hoje?

-- Decisões de recorte aplicadas:
-- - Recorte temporal: aplicado via vw_stg_orders_validos
--   (ver validacao/02_recorte_temporal.sql)
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
JOIN vw_stg_orders_validos vsov 
	ON oi.order_id = vsov.order_id
WHERE vsov.order_status != 'canceled'
GROUP BY 
	p.product_category_name, 
	pcnt.product_category_name_english
ORDER BY receita DESC


-- ===================== Achados =====================
-- As três categorias de produto que trazem mais receita atualmente são:
-- Beleza e saúde: R$ 1.251.145,54
-- Relógios e presentes: R$ 1.194.824,97
-- Cama, mesa e banho: R$ 1.035.485,07


-- ========= Aprendizados com essa consulta =========
-- Descobri que deveria usar LEFT JOIN por causa dos 610 produtos que não possuíam categoria na tabela products.
-- Se não usasse LEFT JOIN, a receita gerada por esses produtos seria negligenciada na consulta
--
-- Além disso, descobri o uso prático da função COALESCE, que foi útil para nomear a categoria de produtos "não informado".