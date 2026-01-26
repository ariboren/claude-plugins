---
name: sql-pro
description: SQL expertise for query optimization, database design, and performance tuning across PostgreSQL, MySQL, SQL Server, and Oracle. Use when writing complex queries, optimizing performance, or designing schemas.
---

# SQL Expertise

## Query Optimization

### Execution Plan Analysis

```sql
-- PostgreSQL
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE customer_id = 123;

-- MySQL
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 123;

-- SQL Server
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```

Red Flags in Plans:

- Sequential/Table Scan on large tables
- Nested Loop with large outer table
- Sort operations without index
- Hash joins with memory spills
- High actual vs estimated rows difference

### Index Strategies

```sql
-- Covering index (includes all needed columns)
CREATE INDEX idx_orders_covering
ON orders (customer_id)
INCLUDE (order_date, total);

-- Partial index (filtered)
CREATE INDEX idx_orders_pending
ON orders (created_at)
WHERE status = 'pending';

-- Composite index (order matters!)
-- Supports: (a), (a,b), (a,b,c)
-- Does NOT support: (b), (b,c), (c)
CREATE INDEX idx_composite
ON orders (customer_id, order_date, status);
```

## Advanced Query Patterns

### Window Functions

```sql
-- Running total
SELECT
    order_date,
    amount,
    SUM(amount) OVER (
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) as running_total
FROM orders;

-- Rank within groups
SELECT
    department,
    employee,
    salary,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) as dept_rank
FROM employees;

-- Lead/Lag for comparisons
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) as prev_month,
    revenue - LAG(revenue) OVER (ORDER BY month) as growth
FROM monthly_stats;
```

### Common Table Expressions (CTEs)

```sql
-- Recursive CTE for hierarchies
WITH RECURSIVE org_chart AS (
    -- Base case: top-level managers
    SELECT id, name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: employees with managers
    SELECT e.id, e.name, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart;
```

### Efficient Joins

```sql
-- EXISTS vs IN (EXISTS often faster for correlated)
-- Good
SELECT * FROM orders o
WHERE EXISTS (
    SELECT 1 FROM customers c
    WHERE c.id = o.customer_id
    AND c.status = 'active'
);

-- Avoid (subquery executes for every row)
SELECT * FROM orders
WHERE customer_id IN (
    SELECT id FROM customers WHERE status = 'active'
);
```

## Performance Patterns

### Pagination

```sql
-- Offset pagination (slow for large offsets)
SELECT * FROM orders
ORDER BY created_at DESC
LIMIT 20 OFFSET 10000;  -- Scans 10020 rows!

-- Cursor pagination (fast and stable)
SELECT * FROM orders
WHERE created_at < '2024-01-15T10:30:00'
ORDER BY created_at DESC
LIMIT 20;
```

### Batch Operations

```sql
-- Batch updates to avoid lock contention
UPDATE orders
SET status = 'archived'
WHERE id IN (
    SELECT id FROM orders
    WHERE created_at < '2023-01-01'
    AND status != 'archived'
    LIMIT 1000
);
-- Run in loop until 0 rows affected
```

### Avoiding N+1

```sql
-- Bad: Separate query per order
SELECT * FROM orders WHERE id = 1;
SELECT * FROM order_items WHERE order_id = 1;
SELECT * FROM orders WHERE id = 2;
SELECT * FROM order_items WHERE order_id = 2;
-- ...

-- Good: Single join query
SELECT o.*, oi.*
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.customer_id = 123;
```

## Database-Specific Features

### PostgreSQL

```sql
-- JSONB querying
SELECT * FROM events
WHERE data @> '{"type": "purchase"}'
AND data->>'amount' > '100';

-- Array operations
SELECT * FROM users
WHERE 'admin' = ANY(roles);

-- Full-text search
SELECT * FROM articles
WHERE to_tsvector('english', body) @@ to_tsquery('search & term');
```

### MySQL

```sql
-- JSON querying
SELECT * FROM events
WHERE JSON_EXTRACT(data, '$.type') = 'purchase';

-- Full-text search
SELECT * FROM articles
WHERE MATCH(title, body) AGAINST('search term' IN BOOLEAN MODE);
```

## Transaction Management

### Isolation Levels

| Level            | Dirty Read | Non-Repeatable | Phantom    |
| ---------------- | ---------- | -------------- | ---------- |
| Read Uncommitted | ✓          | ✓              | ✓          |
| Read Committed   | ✗          | ✓              | ✓          |
| Repeatable Read  | ✗          | ✗              | ✓ (varies) |
| Serializable     | ✗          | ✗              | ✗          |

### Deadlock Prevention

```sql
-- Always access tables in same order
-- Good: orders -> order_items
BEGIN;
UPDATE orders SET status = 'processing' WHERE id = 1;
UPDATE order_items SET status = 'processing' WHERE order_id = 1;
COMMIT;

-- Use SELECT FOR UPDATE to lock explicitly
SELECT * FROM orders WHERE id = 1 FOR UPDATE;
```

## Schema Design

### Normalization Guidelines

- 1NF: Atomic values, no repeating groups
- 2NF: No partial dependencies on composite keys
- 3NF: No transitive dependencies

Denormalize only when:

- Read performance is critical
- Data is rarely updated
- Measured, proven benefit

### Data Types

```sql
-- Use appropriate types
-- Bad
CREATE TABLE users (
    phone VARCHAR(255),
    created_at VARCHAR(255),
    is_active VARCHAR(10)
);

-- Good
CREATE TABLE users (
    phone VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);
```

## Quality Checklist

- [ ] EXPLAIN ANALYZE shows no sequential scans on large tables
- [ ] Query performance < 100ms target
- [ ] Indexes cover common query patterns
- [ ] No N+1 query patterns
- [ ] Transactions use appropriate isolation
- [ ] Batch operations for bulk changes
- [ ] Statistics up to date
- [ ] Connection pooling configured
