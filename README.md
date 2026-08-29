# Análise de e-commerce utilizando SQL

Projeto de análise de dados com SQL utilizando como DBMS o MySQL, simulando o tipo de análise que um analista faria dentro de um marketplace, olhando vendas, avaliações de clientes, comportamento por estado e status de pedidos.

## Sobre o projeto

Depois do projeto de risco de crédito, quis praticar em um cenário diferente, mais próximo do dia a dia de e-commerce/varejo: entender quais categorias vendem mais, como os clientes avaliam os pedidos, quais estados gastam mais e como estão os status das entregas. Também usei esse projeto para evoluir de subquery simples para CTE encadeada (WITH) e CROSS JOIN, que não tinha usado ainda no projeto anterior.

## Dataset

- Fonte: [Olist Brazilian E-Commerce Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 9 tabelas relacionadas: clientes, pedidos, itens do pedido, pagamentos, avaliações, produtos, vendedores, geolocalização e tradução de categoria de produto

## Estrutura do banco de dados

- `customers` (id_cliente, estado, cidade, ...)
- `orders` (id_pedido, id_cliente FK, status_pedido, datas, ...)
- `order_items` (id_pedido FK, id_produto FK, id_vendedor FK, preço, frete)
- `order_payments` (id_pedido FK, valor_pagamento, parcelas)
- `order_reviews` (id_pedido FK, nota_avaliacao)
- `products` (id_produto, categoria, peso, dimensões)
- `sellers` (id_vendedor, cidade, estado)

Relacionamento principal: um cliente pode ter vários pedidos, um pedido pode ter vários itens, e cada item liga um produto a um vendedor.

## Principais queries

**1. Total de vendas por categoria de produto**

```sql
SELECT 
    p.product_category_name,
    SUM(oi.price) AS total_vendas
FROM order_items oi
JOIN products p USING(product_id)
GROUP BY p.product_category_name
ORDER BY total_vendas DESC;
```
Query básica de JOIN + agregação, pra ver de cara quais categorias faturam mais.

**2. Classificação de avaliações por sentimento**

```sql
SELECT
    review_id,
    CASE
        WHEN review_score IN(1,2) THEN 'Negativa'
        WHEN review_score = 3 THEN 'Neutra'
        ELSE 'Positiva'
    END AS tipo_avaliacao
FROM order_reviews;
```
Aqui uso CASE WHEN pra transformar a nota (1 a 5) em uma categoria de sentimento, o que facilita bastante quando você quer olhar satisfação geral em vez de nota isolada.

**3. Vendedores sem nenhuma venda registrada**

```sql
SELECT seller_id
FROM sellers s
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.seller_id = s.seller_id
);
```
Usei NOT EXISTS em vez de NOT IN de propósito: NOT IN quebra silenciosamente e retorna zero linhas quando a subquery tem algum valor NULL, então NOT EXISTS é mais seguro pra esse tipo de checagem.

**4. Faturamento por categoria comparado à média geral (CTE dupla + CROSS JOIN)**

```sql
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
```
Essa foi a query que mais me ajudou a entender CTE encadeada: a primeira CTE calcula a soma por categoria, a segunda calcula a média geral em cima do resultado da primeira, e o CROSS JOIN junta as duas pra comparar cada categoria com a média de todas.

**5. Gasto por estado vs. média nacional, com status**

```sql
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
```
Aqui dá pra ver claramente que SP concentra o maior volume de gasto, bem acima da média nacional, enquanto boa parte dos outros estados fica abaixo.

## O que aprendi

Esse projeto foi onde consolidei CTE dupla e CROSS JOIN, que ainda não tinha usado no projeto de risco de crédito. Pretendo seguir evoluindo cada vez mais em SQL para assim poder aplicar no meu dia a dia no trabalho, próximo passo é entender Window Function e aperfeiçoar meus conhecimentos.

## Autor

David Lucas - [GitHub](https://github.com/David-L-Santos)