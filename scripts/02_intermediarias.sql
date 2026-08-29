-- OLIST E-COMMERCE ANALYSIS
-- QUERIES INTERMEDIÁRIAS: Subquery e CASE WHEN
-- ========================================================

-- QUERY 1: Classificação de avaliações por sentimento
-- Ferramentas: CASE WHEN, GROUP BY

SELECT
    review_id,
    CASE
        WHEN review_score IN(1,2) THEN 'Negativa'
        WHEN review_score = 3 THEN 'Neutra'
        ELSE 'Positiva'
    END AS tipo_avaliacao
FROM order_reviews;

-- ========================================================

-- QUERY 2: Classificação de status de pedidos
-- Ferramentas: CASE WHEN, WHERE

SELECT
    order_id,
    CASE
        WHEN order_status = 'delivered' THEN 'Entregue'
        WHEN order_status = 'canceled' THEN 'Cancelado'
        ELSE 'Outro status'
    END AS status_pedido
FROM orders;

-- ========================================================

-- QUERY 3: Classificação de produtos por faixa de peso
-- Ferramentas: CASE WHEN, JOIN

SELECT
    p.product_id,
    oi.price,
    CASE
        WHEN p.product_weight_g < 1000 THEN 'Leve'
        WHEN p.product_weight_g BETWEEN 1000 AND 5000 THEN 'Médio'
        ELSE 'Pesado'
    END AS peso_produto
FROM products p
JOIN order_items oi USING(product_id);

-- ========================================================

-- QUERY 4: Vendedores sem atividade
-- Ferramentas: WHERE, NOT EXISTS, Subquery
-- Obs: usa NOT EXISTS em vez de NOT IN para evitar o problema
-- de NOT IN retornar zero linhas quando a subquery tem NULL.

SELECT seller_id
FROM sellers s
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.seller_id = s.seller_id
);

-- ========================================================

-- QUERY 5: Itens com preço acima da média geral
-- Ferramentas: WHERE, Subquery, ORDER BY

SELECT
    order_id,
    price
FROM order_items
WHERE price > (
    SELECT AVG(price) FROM order_items
)
ORDER BY price DESC
LIMIT 20;

-- ========================================================
