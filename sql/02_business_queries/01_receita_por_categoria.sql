-- ============================================================
-- Pergunta de negócio 01
-- Requerente: Diretoria/Executivo
-- Pergunta: Quais categorias de produto trazem mais receita hoje?
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
GROUP BY 
	p.product_category_name, 
	pcnt.product_category_name_english
ORDER BY receita DESC

-- As três categorias de produto que trazem mais receita atualmente são:
-- Beleza e saúde: R$ 1.258.681,34
-- Relógios e presentes: R$ 1.205.005,68
-- Cama, mesa e banho: R$ 1.036.988,68

-- OBS: a receita não inclui o valor do frete

-- ========= Aprendizados com essa consulta =========
-- Descobri que deveria usar LEFT JOIN por causa dos 610 produtos que não possuíam categoria na tabela products.
-- Se não usasse LEFT JOIN, a receita gerada por esses produtos seria negligenciada na consulta

-- Além disso, descobri o uso prático da função COALESCE, que foi útil para nomear a categoria de produtos "não informado".