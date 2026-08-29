-- =====================================================
-- OLIST E-COMMERCE ANALYSIS
-- QUERIES BÁSICAS: JOIN e Agregações
-- =====================================================

-- QUERY 1: Total de vendas por categoria de produto
-- Ferramentas: JOIN, GROUP BY, SUM, ORDER BY

SELECT 
    p.product_category_name,
    SUM(oi.price) AS total_vendas
FROM order_items oi
JOIN products p USING(product_id)
GROUP BY p.product_category_name
ORDER BY total_vendas DESC;

-- =====================================================

-- QUERY 2: Total de vendas por vendedor com localização
-- Ferramentas: JOIN, GROUP BY, SUM, ORDER BY

SELECT 
    s.seller_id,
    s.seller_city,
    SUM(oi.price) AS soma
FROM order_items oi
JOIN sellers s USING(seller_id)
GROUP BY s.seller_id, s.seller_city
ORDER BY soma DESC;

-- =====================================================

-- QUERY 3: Produtos com preço, categoria e vendedor
-- Ferramentas: JOIN múltiplo, WHERE, ORDER BY

SELECT 
    oi.price,
    p.product_category_name,
    s.seller_id
FROM order_items oi
JOIN products p USING(product_id)
JOIN sellers s USING(seller_id)
WHERE p.product_category_name IS NOT NULL
    AND p.product_category_name != ''
ORDER BY oi.price DESC;

-- =====================================================

-- QUERY 4: Total de pedidos por estado
-- Ferramentas: JOIN, GROUP BY, COUNT, ORDER BY

SELECT 
    c.customer_state,
    COUNT(*) AS total
FROM customers c
JOIN orders o USING(customer_id)
GROUP BY c.customer_state
ORDER BY total DESC;

-- =====================================================

-- QUERY 5: Classificação de pagamentos (à vista vs parcelado)
-- Ferramentas: CASE WHEN, GROUP BY, COUNT

SELECT 
    CASE 
        WHEN payment_installments = 1 THEN 'À vista'
        ELSE 'Parcelado'
    END AS tipo_pagamento,
    COUNT(order_id) AS quantidade
FROM order_payments
GROUP BY tipo_pagamento;

-- =====================================================
