-- =====================================================
-- OLIST E-COMMERCE ANALYSIS
-- WINDOW FUNCTIONS: RANK, ROW_NUMBER, AVG OVER
-- =====================================================

-- QUERY 1: Ranking de produtos por preço dentro de cada categoria
-- Ferramentas: RANK, PARTITION BY

SELECT product_id, product_category_name, price,
    RANK() OVER(PARTITION BY product_category_name ORDER BY price DESC) AS posicao
FROM products p
JOIN order_items oi USING(product_id)
WHERE product_category_name IS NOT NULL
    AND product_category_name != '';

-- =====================================================

-- QUERY 2: Numerando vendas apenas de produtos com variação real de preço
-- Ferramentas: ROW_NUMBER, subquery com HAVING

SELECT product_id, price,
    ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY price DESC) AS posicao
FROM order_items
WHERE product_id IN (
    SELECT product_id FROM order_items
    GROUP BY product_id
    HAVING COUNT(DISTINCT price) > 1
);

-- =====================================================

-- QUERY 3: Ranking de itens dentro de pedidos com mais de 1 item
-- Ferramentas: RANK, subquery com HAVING

SELECT order_id, price,
    RANK() OVER(PARTITION BY order_id ORDER BY price DESC) AS posicao
FROM order_items
WHERE order_id IN (
    SELECT order_id FROM order_items
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id;

-- =====================================================

-- QUERY 4: Classificação de produtos por faixa de peso, com ranking interno
-- Ferramentas: CTE, CASE WHEN, ROW_NUMBER
-- Obs: NULO tratado antes de LEVE para não ser capturado incorretamente

WITH produtos_peso AS (
    SELECT product_id, product_weight_g,
        CASE
            WHEN product_weight_g IS NULL OR product_weight_g = 0 THEN 'NULO'
            WHEN product_weight_g <= 500 THEN 'LEVE'
            WHEN product_weight_g BETWEEN 501 AND 700 THEN 'MEDIO'
            ELSE 'PESADO'
        END AS categoria_peso
    FROM products
)
SELECT product_id, product_weight_g AS peso_gramas, categoria_peso,
    ROW_NUMBER() OVER(PARTITION BY categoria_peso ORDER BY product_weight_g) AS posicao
FROM produtos_peso
ORDER BY peso_gramas;

-- =====================================================

-- QUERY 5: Comparando o preço de cada item com a média da categoria
-- Ferramentas: AVG OVER (função agregada como window function)

SELECT product_id, product_category_name, price,
    ROUND(AVG(price) OVER(PARTITION BY product_category_name), 2) AS media_categoria,
    ROUND(price - AVG(price) OVER(PARTITION BY product_category_name), 2) AS diferenca_da_media
FROM products p
JOIN order_items oi USING(product_id)
WHERE product_category_name IS NOT NULL
    AND product_category_name != '';

-- =====================================================
