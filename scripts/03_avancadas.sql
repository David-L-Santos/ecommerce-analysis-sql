-- OLIST E-COMMERCE ANALYSIS
-- QUERIES AVANÇADAS: CTE dupla, CROSS JOIN
-- ========================================================

-- QUERY 1: Faturamento por categoria vs. média geral
-- Ferramentas: CTE dupla, CROSS JOIN

WITH vendas_por_categoria AS (
    SELECT
        ROUND(SUM(price), 2) AS soma,
        product_category_name
    FROM order_items oi
    JOIN products p USING(product_id)
    GROUP BY product_category_name
),
media_geral AS (
    SELECT AVG(soma) AS media FROM vendas_por_categoria
)
SELECT
    vpc.product_category_name,
    vpc.soma,
    ROUND(mg.media, 2) AS media
FROM vendas_por_categoria vpc
CROSS JOIN media_geral mg
ORDER BY vpc.soma DESC;

-- ========================================================

-- QUERY 2: Percentual de cada nota de review
-- Ferramentas: CTE dupla, CROSS JOIN

WITH contagem_por_nota AS (
    SELECT
        review_score,
        COUNT(*) AS qtd
    FROM order_reviews
    GROUP BY review_score
),
total_geral AS (
    SELECT SUM(qtd) AS total FROM contagem_por_nota
)
SELECT
    cpn.review_score,
    cpn.qtd,
    tq.total,
    ROUND(cpn.qtd / tq.total * 100, 2) AS percentual
FROM contagem_por_nota cpn
CROSS JOIN total_geral tq
ORDER BY cpn.review_score;

-- ========================================================

-- QUERY 3: Gasto por estado vs. média nacional
-- Ferramentas: CTE dupla, CROSS JOIN, CASE WHEN

WITH gasto_por_estado AS (
    SELECT
        SUM(payment_value) AS soma,
        customer_state
    FROM customers c
    JOIN orders o USING(customer_id)
    JOIN order_payments op USING(order_id)
    GROUP BY customer_state
),
media_nacional AS (
    SELECT AVG(soma) AS media FROM gasto_por_estado
)
SELECT
    gpe.customer_state,
    gpe.soma,
    ROUND(mn.media, 2) AS media_nacional,
    ROUND(gpe.soma - mn.media, 2) AS diferenca,
    CASE
        WHEN gpe.soma > mn.media THEN 'Acima da média'
        WHEN gpe.soma = mn.media THEN 'Igual à média'
        ELSE 'Abaixo da média'
    END AS status
FROM gasto_por_estado gpe
CROSS JOIN media_nacional mn
ORDER BY gpe.soma DESC;

-- ========================================================

-- QUERY 4: Contagem de pedidos por status com percentual
-- Ferramentas: CTE dupla, CROSS JOIN

WITH contagem_status AS (
    SELECT
        COUNT(*) AS qtd,
        order_status
    FROM orders
    GROUP BY order_status
),
total_pedidos AS (
    SELECT COUNT(*) AS total FROM orders
)
SELECT
    cs.qtd,
    cs.order_status,
    tp.total,
    ROUND(cs.qtd / tp.total * 100, 2) AS percentual
FROM contagem_status cs
CROSS JOIN total_pedidos tp
ORDER BY percentual DESC;

-- ========================================================

-- QUERY 5: Distribuição de produtos por faixa de peso
-- Ferramentas: CASE WHEN, GROUP BY
-- Obs: trata peso NULL/0 separadamente para não distorcer
-- a categoria "Pesado".

WITH produtos_por_peso AS (
    SELECT
    CASE
        WHEN product_weight_g IS NULL OR product_weight_g = 0 THEN 'Desconhecido'
        WHEN product_weight_g < 1000 THEN 'Leve'
        WHEN product_weight_g BETWEEN 1000 AND 5000 THEN 'Médio'
        ELSE 'Pesado'
    END AS peso
    FROM products
)
SELECT
    COUNT(*) AS total,
    peso
FROM produtos_por_peso
GROUP BY peso
ORDER BY total DESC;

-- ========================================================
