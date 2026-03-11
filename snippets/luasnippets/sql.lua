-- SQL Snippets for vim-dadbod and general SQL editing
-- Comprehensive snippets for database operations
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

return {
    -- ============================================================
    -- SELECT QUERIES
    -- ============================================================

    -- Basic SELECT
    s("sel", {
        t("SELECT "), i(1, "*"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "condition"),
        t(";"),
    }),

    -- SELECT with alias
    s("sela", {
        t("SELECT "), i(1, "columns"),
        t({ "", "FROM " }), i(2, "table_name"), t(" AS "), i(3, "t"),
        t({ "", "WHERE " }), i(4, "condition"),
        t(";"),
    }),

    -- SELECT DISTINCT
    s("seld", {
        t("SELECT DISTINCT "), i(1, "column"),
        t({ "", "FROM " }), i(2, "table_name"),
        t(";"),
    }),

    -- SELECT with ORDER BY
    s("selo", {
        t("SELECT "), i(1, "*"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "1=1"),
        t({ "", "ORDER BY " }), i(4, "column"), t(" "), c(5, { t("ASC"), t("DESC") }),
        t(";"),
    }),

    -- SELECT with LIMIT/OFFSET (pagination)
    s("selp", {
        t("SELECT "), i(1, "*"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "1=1"),
        t({ "", "ORDER BY " }), i(4, "id"),
        t({ "", "LIMIT " }), i(5, "10"), t(" OFFSET "), i(6, "0"),
        t(";"),
    }),

    -- SELECT COUNT
    s("selc", {
        t("SELECT COUNT("), c(1, { t("*"), t("DISTINCT column") }), t(") AS count"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "1=1"),
        t(";"),
    }),

    -- SELECT with GROUP BY
    s("selg", {
        t("SELECT "), i(1, "column"), t(", COUNT(*) AS count"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "1=1"),
        t({ "", "GROUP BY " }), i(4, "column"),
        t({ "", "HAVING COUNT(*) > " }), i(5, "1"),
        t(";"),
    }),

    -- SELECT with aggregations
    s("selagg", {
        t("SELECT"),
        t({ "", "    COUNT(*) AS total," }),
        t({ "", "    SUM(" }), i(1, "amount"), t(") AS sum_total,"),
        t({ "", "    AVG(" }), i(2, "amount"), t(") AS average,"),
        t({ "", "    MIN(" }), i(3, "amount"), t(") AS minimum,"),
        t({ "", "    MAX(" }), i(4, "amount"), t(") AS maximum"),
        t({ "", "FROM " }), i(5, "table_name"),
        t({ "", "WHERE " }), i(6, "1=1"),
        t(";"),
    }),

    -- ============================================================
    -- JOINS
    -- ============================================================

    -- INNER JOIN
    s("join", {
        t("SELECT "), i(1, "a.*, b.*"),
        t({ "", "FROM " }), i(2, "table1"), t(" a"),
        t({ "", "INNER JOIN " }), i(3, "table2"), t(" b ON a."), i(4, "id"), t(" = b."), i(5, "table1_id"),
        t({ "", "WHERE " }), i(6, "1=1"),
        t(";"),
    }),

    -- LEFT JOIN
    s("ljoin", {
        t("SELECT "), i(1, "a.*, b.*"),
        t({ "", "FROM " }), i(2, "table1"), t(" a"),
        t({ "", "LEFT JOIN " }), i(3, "table2"), t(" b ON a."), i(4, "id"), t(" = b."), i(5, "table1_id"),
        t({ "", "WHERE " }), i(6, "1=1"),
        t(";"),
    }),

    -- RIGHT JOIN
    s("rjoin", {
        t("SELECT "), i(1, "a.*, b.*"),
        t({ "", "FROM " }), i(2, "table1"), t(" a"),
        t({ "", "RIGHT JOIN " }), i(3, "table2"), t(" b ON a."), i(4, "id"), t(" = b."), i(5, "table1_id"),
        t({ "", "WHERE " }), i(6, "1=1"),
        t(";"),
    }),

    -- FULL OUTER JOIN
    s("fjoin", {
        t("SELECT "), i(1, "a.*, b.*"),
        t({ "", "FROM " }), i(2, "table1"), t(" a"),
        t({ "", "FULL OUTER JOIN " }), i(3, "table2"), t(" b ON a."), i(4, "id"), t(" = b."), i(5, "table1_id"),
        t({ "", "WHERE " }), i(6, "1=1"),
        t(";"),
    }),

    -- Multiple JOINs
    s("mjoin", {
        t("SELECT "), i(1, "a.*, b.*, c.*"),
        t({ "", "FROM " }), i(2, "table1"), t(" a"),
        t({ "", "INNER JOIN " }), i(3, "table2"), t(" b ON a."), i(4, "id"), t(" = b."), i(5, "table1_id"),
        t({ "", "LEFT JOIN " }), i(6, "table3"), t(" c ON b."), i(7, "id"), t(" = c."), i(8, "table2_id"),
        t({ "", "WHERE " }), i(9, "1=1"),
        t(";"),
    }),

    -- ============================================================
    -- SUBQUERIES
    -- ============================================================

    -- Subquery in WHERE
    s("selsub", {
        t("SELECT "), i(1, "*"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "column"), t(" IN ("),
        t({ "", "    SELECT " }), i(4, "column"),
        t({ "", "    FROM " }), i(5, "other_table"),
        t({ "", "    WHERE " }), i(6, "condition"),
        t({ "", ");" }),
    }),

    -- EXISTS subquery
    s("selexists", {
        t("SELECT "), i(1, "*"),
        t({ "", "FROM " }), i(2, "table1"), t(" a"),
        t({ "", "WHERE EXISTS (" }),
        t({ "", "    SELECT 1" }),
        t({ "", "    FROM " }), i(3, "table2"), t(" b"),
        t({ "", "    WHERE b." }), i(4, "table1_id"), t(" = a."), i(5, "id"),
        t({ "", ");" }),
    }),

    -- CTE (Common Table Expression)
    s("cte", {
        t("WITH "), i(1, "cte_name"), t(" AS ("),
        t({ "", "    SELECT " }), i(2, "*"),
        t({ "", "    FROM " }), i(3, "table_name"),
        t({ "", "    WHERE " }), i(4, "condition"),
        t({ "", ")" }),
        t({ "", "SELECT * FROM " }), i(5, "cte_name"),
        t(";"),
    }),

    -- Multiple CTEs
    s("ctem", {
        t("WITH"),
        t({ "", "    " }), i(1, "cte1"), t(" AS ("),
        t({ "", "        SELECT " }), i(2, "*"), t(" FROM "), i(3, "table1"),
        t({ "", "    )," }),
        t({ "", "    " }), i(4, "cte2"), t(" AS ("),
        t({ "", "        SELECT " }), i(5, "*"), t(" FROM "), i(6, "table2"),
        t({ "", "    )" }),
        t({ "", "SELECT *" }),
        t({ "", "FROM " }), i(7, "cte1"), t(" a"),
        t({ "", "JOIN " }), i(8, "cte2"), t(" b ON a."), i(9, "id"), t(" = b."), i(10, "cte1_id"),
        t(";"),
    }),

    -- ============================================================
    -- INSERT STATEMENTS
    -- ============================================================

    -- Basic INSERT
    s("ins", {
        t("INSERT INTO "), i(1, "table_name"), t(" ("), i(2, "columns"), t(")"),
        t({ "", "VALUES (" }), i(3, "values"), t(");"),
    }),

    -- INSERT with multiple rows
    s("insm", {
        t("INSERT INTO "), i(1, "table_name"), t(" ("), i(2, "col1, col2, col3"), t(")"),
        t({ "", "VALUES" }),
        t({ "", "    (" }), i(3, "val1, val2, val3"), t("),"),
        t({ "", "    (" }), i(4, "val1, val2, val3"), t("),"),
        t({ "", "    (" }), i(5, "val1, val2, val3"), t(");"),
    }),

    -- INSERT with SELECT
    s("inssel", {
        t("INSERT INTO "), i(1, "target_table"), t(" ("), i(2, "columns"), t(")"),
        t({ "", "SELECT " }), i(3, "columns"),
        t({ "", "FROM " }), i(4, "source_table"),
        t({ "", "WHERE " }), i(5, "condition"),
        t(";"),
    }),

    -- INSERT with RETURNING (PostgreSQL)
    s("insret", {
        t("INSERT INTO "), i(1, "table_name"), t(" ("), i(2, "columns"), t(")"),
        t({ "", "VALUES (" }), i(3, "values"), t(")"),
        t({ "", "RETURNING " }), i(4, "*"),
        t(";"),
    }),

    -- INSERT ON CONFLICT (PostgreSQL upsert)
    s("upsert", {
        t("INSERT INTO "), i(1, "table_name"), t(" ("), i(2, "id, column1, column2"), t(")"),
        t({ "", "VALUES (" }), i(3, "values"), t(")"),
        t({ "", "ON CONFLICT (" }), i(4, "id"), t(")"),
        t({ "", "DO UPDATE SET" }),
        t({ "", "    " }), i(5, "column1"), t(" = EXCLUDED."), i(6, "column1"), t(","),
        t({ "", "    " }), i(7, "column2"), t(" = EXCLUDED."), i(8, "column2"),
        t(";"),
    }),

    -- INSERT IGNORE (MySQL)
    s("insig", {
        t("INSERT IGNORE INTO "), i(1, "table_name"), t(" ("), i(2, "columns"), t(")"),
        t({ "", "VALUES (" }), i(3, "values"), t(");"),
    }),

    -- ============================================================
    -- UPDATE STATEMENTS
    -- ============================================================

    -- Basic UPDATE
    s("upd", {
        t("UPDATE "), i(1, "table_name"),
        t({ "", "SET " }), i(2, "column"), t(" = "), i(3, "value"),
        t({ "", "WHERE " }), i(4, "condition"),
        t(";"),
    }),

    -- UPDATE multiple columns
    s("updm", {
        t("UPDATE "), i(1, "table_name"),
        t({ "", "SET" }),
        t({ "", "    " }), i(2, "column1"), t(" = "), i(3, "value1"), t(","),
        t({ "", "    " }), i(4, "column2"), t(" = "), i(5, "value2"), t(","),
        t({ "", "    " }), i(6, "updated_at"), t(" = "), c(7, { t("NOW()"), t("CURRENT_TIMESTAMP"), t("GETDATE()") }),
        t({ "", "WHERE " }), i(8, "id"), t(" = "), i(9, "value"),
        t(";"),
    }),

    -- UPDATE with JOIN
    s("updj", {
        t("UPDATE "), i(1, "t1"),
        t({ "", "SET t1." }), i(2, "column"), t(" = t2."), i(3, "column"),
        t({ "", "FROM " }), i(4, "table1"), t(" t1"),
        t({ "", "INNER JOIN " }), i(5, "table2"), t(" t2 ON t1."), i(6, "id"), t(" = t2."), i(7, "table1_id"),
        t({ "", "WHERE " }), i(8, "condition"),
        t(";"),
    }),

    -- UPDATE with subquery
    s("upds", {
        t("UPDATE "), i(1, "table_name"),
        t({ "", "SET " }), i(2, "column"), t(" = ("),
        t({ "", "    SELECT " }), i(3, "value"),
        t({ "", "    FROM " }), i(4, "other_table"),
        t({ "", "    WHERE " }), i(5, "condition"),
        t({ "", "    LIMIT 1" }),
        t({ "", ")" }),
        t({ "", "WHERE " }), i(6, "condition"),
        t(";"),
    }),

    -- ============================================================
    -- DELETE STATEMENTS
    -- ============================================================

    -- Basic DELETE
    s("del", {
        t("DELETE FROM "), i(1, "table_name"),
        t({ "", "WHERE " }), i(2, "condition"),
        t(";"),
    }),

    -- DELETE with JOIN
    s("delj", {
        t("DELETE t1"),
        t({ "", "FROM " }), i(1, "table1"), t(" t1"),
        t({ "", "INNER JOIN " }), i(2, "table2"), t(" t2 ON t1."), i(3, "id"), t(" = t2."), i(4, "table1_id"),
        t({ "", "WHERE " }), i(5, "condition"),
        t(";"),
    }),

    -- DELETE with subquery
    s("dels", {
        t("DELETE FROM "), i(1, "table_name"),
        t({ "", "WHERE " }), i(2, "id"), t(" IN ("),
        t({ "", "    SELECT " }), i(3, "id"),
        t({ "", "    FROM " }), i(4, "other_table"),
        t({ "", "    WHERE " }), i(5, "condition"),
        t({ "", ");" }),
    }),

    -- TRUNCATE
    s("trunc", {
        t("TRUNCATE TABLE "), i(1, "table_name"), t(";"),
    }),

    -- ============================================================
    -- CREATE TABLE
    -- ============================================================

    -- Basic CREATE TABLE
    s("crt", {
        t("CREATE TABLE "), i(1, "table_name"), t(" ("),
        t({ "", "    " }), i(2, "id"), t(" "), c(3, { t("SERIAL PRIMARY KEY"), t("INT AUTO_INCREMENT PRIMARY KEY"), t("INTEGER PRIMARY KEY AUTOINCREMENT") }), t(","),
        t({ "", "    " }), i(4, "name"), t(" VARCHAR("), i(5, "255"), t(") NOT NULL,"),
        t({ "", "    " }), i(6, "created_at"), t(" TIMESTAMP DEFAULT "), c(7, { t("NOW()"), t("CURRENT_TIMESTAMP"), t("GETDATE()") }),
        t({ "", ");" }),
    }),

    -- CREATE TABLE with foreign key
    s("crtfk", {
        t("CREATE TABLE "), i(1, "table_name"), t(" ("),
        t({ "", "    " }), i(2, "id"), t(" SERIAL PRIMARY KEY,"),
        t({ "", "    " }), i(3, "parent_id"), t(" INT NOT NULL,"),
        t({ "", "    " }), i(4, "name"), t(" VARCHAR(255) NOT NULL,"),
        t({ "", "    " }), i(5, "created_at"), t(" TIMESTAMP DEFAULT NOW(),"),
        t({ "", "    CONSTRAINT fk_" }), i(6, "parent"),
        t({ "", "        FOREIGN KEY (" }), i(7, "parent_id"), t(")"),
        t({ "", "        REFERENCES " }), i(8, "parent_table"), t("("), i(9, "id"), t(")"),
        t({ "", "        ON DELETE " }), c(10, { t("CASCADE"), t("SET NULL"), t("RESTRICT"), t("NO ACTION") }),
        t({ "", ");" }),
    }),

    -- CREATE TABLE full template
    s("crtfull", {
        t("CREATE TABLE IF NOT EXISTS "), i(1, "table_name"), t(" ("),
        t({ "", "    id SERIAL PRIMARY KEY," }),
        t({ "", "    " }), i(2, "name"), t(" VARCHAR(255) NOT NULL,"),
        t({ "", "    " }), i(3, "email"), t(" VARCHAR(255) UNIQUE,"),
        t({ "", "    " }), i(4, "status"), t(" VARCHAR(50) DEFAULT 'active',"),
        t({ "", "    " }), i(5, "is_active"), t(" BOOLEAN DEFAULT TRUE,"),
        t({ "", "    " }), i(6, "metadata"), t(" JSONB,"),
        t({ "", "    created_at TIMESTAMP DEFAULT NOW()," }),
        t({ "", "    updated_at TIMESTAMP DEFAULT NOW()," }),
        t({ "", "    deleted_at TIMESTAMP NULL" }),
        t({ "", ");" }),
        t({ "", "" }),
        t({ "", "CREATE INDEX idx_" }), f(function(args) return args[1][1]:lower() end, { 1 }), t("_"), i(7, "status"),
        t({ "", "    ON " }), f(function(args) return args[1][1] end, { 1 }), t("("), f(function(args) return args[1][1] end, { 7 }), t(");"),
    }),

    -- ============================================================
    -- ALTER TABLE
    -- ============================================================

    -- ADD COLUMN
    s("altadd", {
        t("ALTER TABLE "), i(1, "table_name"),
        t({ "", "ADD COLUMN " }), i(2, "column_name"), t(" "), i(3, "VARCHAR(255)"), t(" "), c(4, { t("NULL"), t("NOT NULL") }),
        t(";"),
    }),

    -- DROP COLUMN
    s("altdrop", {
        t("ALTER TABLE "), i(1, "table_name"),
        t({ "", "DROP COLUMN " }), i(2, "column_name"),
        t(";"),
    }),

    -- MODIFY/ALTER COLUMN
    s("altmod", {
        t("ALTER TABLE "), i(1, "table_name"),
        t({ "", "ALTER COLUMN " }), i(2, "column_name"), t(" TYPE "), i(3, "new_type"),
        t(";"),
    }),

    -- RENAME COLUMN
    s("altren", {
        t("ALTER TABLE "), i(1, "table_name"),
        t({ "", "RENAME COLUMN " }), i(2, "old_name"), t(" TO "), i(3, "new_name"),
        t(";"),
    }),

    -- ADD CONSTRAINT
    s("altcon", {
        t("ALTER TABLE "), i(1, "table_name"),
        t({ "", "ADD CONSTRAINT " }), i(2, "constraint_name"),
        t({ "", "    " }), c(3, {
            t({ "FOREIGN KEY (column) REFERENCES other_table(id)" }),
            t({ "UNIQUE (column)" }),
            t({ "CHECK (condition)" }),
        }),
        t(";"),
    }),

    -- ADD INDEX
    s("creidx", {
        t("CREATE "), c(1, { t(""), t("UNIQUE ") }), t("INDEX "), i(2, "idx_name"),
        t({ "", "ON " }), i(3, "table_name"), t(" ("), i(4, "columns"), t(");"),
    }),

    -- DROP INDEX
    s("dropidx", {
        t("DROP INDEX "), c(1, { t("IF EXISTS "), t("") }), i(2, "idx_name"), t(";"),
    }),

    -- ============================================================
    -- TRANSACTIONS
    -- ============================================================

    -- Transaction block
    s("trans", {
        t("BEGIN;"),
        t({ "", "" }),
        t({ "", "-- " }), i(1, "Your SQL statements here"),
        t({ "", "" }),
        t({ "", "-- COMMIT; -- Uncomment to commit" }),
        t({ "", "-- ROLLBACK; -- Uncomment to rollback" }),
    }),

    -- Transaction with savepoint
    s("transsp", {
        t("BEGIN;"),
        t({ "", "" }),
        t({ "", "SAVEPOINT " }), i(1, "savepoint_name"), t(";"),
        t({ "", "" }),
        t({ "", "-- " }), i(2, "Operations"),
        t({ "", "" }),
        t({ "", "-- ROLLBACK TO " }), f(function(args) return args[1][1] end, { 1 }), t("; -- Rollback to savepoint"),
        t({ "", "-- RELEASE SAVEPOINT " }), f(function(args) return args[1][1] end, { 1 }), t("; -- Release savepoint"),
        t({ "", "" }),
        t({ "", "COMMIT;" }),
    }),

    -- ============================================================
    -- VIEWS
    -- ============================================================

    -- CREATE VIEW
    s("view", {
        t("CREATE "), c(1, { t(""), t("OR REPLACE ") }), t("VIEW "), i(2, "view_name"), t(" AS"),
        t({ "", "SELECT " }), i(3, "columns"),
        t({ "", "FROM " }), i(4, "table_name"),
        t({ "", "WHERE " }), i(5, "condition"),
        t(";"),
    }),

    -- Materialized view (PostgreSQL)
    s("matview", {
        t("CREATE MATERIALIZED VIEW "), i(1, "view_name"), t(" AS"),
        t({ "", "SELECT " }), i(2, "columns"),
        t({ "", "FROM " }), i(3, "table_name"),
        t({ "", "WHERE " }), i(4, "1=1"),
        t({ "", "WITH DATA;" }),
        t({ "", "" }),
        t({ "", "-- REFRESH MATERIALIZED VIEW " }), f(function(args) return args[1][1] end, { 1 }), t(";"),
    }),

    -- ============================================================
    -- STORED PROCEDURES / FUNCTIONS
    -- ============================================================

    -- PostgreSQL function
    s("func", {
        t("CREATE OR REPLACE FUNCTION "), i(1, "function_name"), t("("),
        t({ "", "    " }), i(2, "param1 INT, param2 VARCHAR"),
        t({ "", ")" }),
        t({ "", "RETURNS " }), c(3, { t("TABLE(col1 INT, col2 VARCHAR)"), t("INT"), t("VARCHAR"), t("BOOLEAN"), t("VOID") }),
        t({ "", "LANGUAGE " }), c(4, { t("plpgsql"), t("sql") }),
        t({ "", "AS $$" }),
        t({ "", "BEGIN" }),
        t({ "", "    " }), i(5, "-- Function body"),
        t({ "", "    RETURN QUERY SELECT * FROM table_name;" }),
        t({ "", "END;" }),
        t({ "", "$$;" }),
    }),

    -- MySQL stored procedure
    s("proc", {
        t("DELIMITER //"),
        t({ "", "CREATE PROCEDURE " }), i(1, "procedure_name"), t("("),
        t({ "", "    IN " }), i(2, "param1"), t(" "), i(3, "INT"), t(","),
        t({ "", "    OUT " }), i(4, "result"), t(" "), i(5, "INT"),
        t({ "", ")" }),
        t({ "", "BEGIN" }),
        t({ "", "    " }), i(6, "-- Procedure body"),
        t({ "", "END //" }),
        t({ "", "DELIMITER ;" }),
    }),

    -- ============================================================
    -- TRIGGERS
    -- ============================================================

    -- PostgreSQL trigger
    s("trig", {
        t("CREATE OR REPLACE FUNCTION "), i(1, "trigger_function"), t("()"),
        t({ "", "RETURNS TRIGGER AS $$" }),
        t({ "", "BEGIN" }),
        t({ "", "    NEW.updated_at = NOW();" }),
        t({ "", "    RETURN NEW;" }),
        t({ "", "END;" }),
        t({ "", "$$ LANGUAGE plpgsql;" }),
        t({ "", "" }),
        t({ "", "CREATE TRIGGER " }), i(2, "trigger_name"),
        t({ "", "    BEFORE " }), c(3, { t("UPDATE"), t("INSERT"), t("DELETE") }),
        t({ "", "    ON " }), i(4, "table_name"),
        t({ "", "    FOR EACH ROW" }),
        t({ "", "    EXECUTE FUNCTION " }), f(function(args) return args[1][1] end, { 1 }), t("();"),
    }),

    -- ============================================================
    -- UTILITY QUERIES
    -- ============================================================

    -- Find duplicates
    s("dup", {
        t("SELECT "), i(1, "column"), t(", COUNT(*) AS count"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "GROUP BY " }), f(function(args) return args[1][1] end, { 1 }),
        t({ "", "HAVING COUNT(*) > 1" }),
        t({ "", "ORDER BY count DESC;" }),
    }),

    -- Table info (PostgreSQL)
    s("tinfo", {
        t("SELECT"),
        t({ "", "    column_name," }),
        t({ "", "    data_type," }),
        t({ "", "    character_maximum_length," }),
        t({ "", "    is_nullable," }),
        t({ "", "    column_default" }),
        t({ "", "FROM information_schema.columns" }),
        t({ "", "WHERE table_name = '" }), i(1, "table_name"), t("'"),
        t({ "", "ORDER BY ordinal_position;" }),
    }),

    -- Table sizes (PostgreSQL)
    s("tsize", {
        t("SELECT"),
        t({ "", "    relname AS table_name," }),
        t({ "", "    pg_size_pretty(pg_total_relation_size(relid)) AS total_size," }),
        t({ "", "    pg_size_pretty(pg_relation_size(relid)) AS data_size," }),
        t({ "", "    pg_size_pretty(pg_indexes_size(relid)) AS index_size" }),
        t({ "", "FROM pg_catalog.pg_statio_user_tables" }),
        t({ "", "ORDER BY pg_total_relation_size(relid) DESC;" }),
    }),

    -- Running queries (PostgreSQL)
    s("runq", {
        t("SELECT"),
        t({ "", "    pid," }),
        t({ "", "    now() - pg_stat_activity.query_start AS duration," }),
        t({ "", "    query," }),
        t({ "", "    state" }),
        t({ "", "FROM pg_stat_activity" }),
        t({ "", "WHERE (now() - pg_stat_activity.query_start) > interval '5 seconds'" }),
        t({ "", "AND state != 'idle';" }),
    }),

    -- Kill query (PostgreSQL)
    s("killq", {
        t("SELECT pg_terminate_backend("), i(1, "pid"), t(");"),
    }),

    -- Explain analyze
    s("expl", {
        t("EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)"),
        t({ "", "SELECT " }), i(1, "*"),
        t({ "", "FROM " }), i(2, "table_name"),
        t({ "", "WHERE " }), i(3, "condition"),
        t(";"),
    }),

    -- Case statement
    s("case", {
        t("CASE"),
        t({ "", "    WHEN " }), i(1, "condition1"), t(" THEN "), i(2, "result1"),
        t({ "", "    WHEN " }), i(3, "condition2"), t(" THEN "), i(4, "result2"),
        t({ "", "    ELSE " }), i(5, "default_result"),
        t({ "", "END" }),
    }),

    -- Coalesce
    s("coal", {
        t("COALESCE("), i(1, "column"), t(", "), i(2, "default_value"), t(")"),
    }),

    -- NULLIF
    s("nullif", {
        t("NULLIF("), i(1, "expression"), t(", "), i(2, "value"), t(")"),
    }),

    -- Date functions
    s("datenow", {
        c(1, {
            t("NOW()"),
            t("CURRENT_TIMESTAMP"),
            t("CURRENT_DATE"),
            t("GETDATE()"),
        }),
    }),

    -- Date interval
    s("dateint", {
        c(1, {
            t("NOW() - INTERVAL '"),
            t("DATE_SUB(NOW(), INTERVAL "),
        }), i(2, "7"), c(3, {
            t(" days'"),
            t(" DAY)"),
        }),
    }),

    -- ============================================================
    -- DATABASE SPECIFIC
    -- ============================================================

    -- PostgreSQL JSON
    s("jsonb", {
        t("SELECT"),
        t({ "", "    " }), i(1, "data"), t("->'"), i(2, "key"), t("' AS value,"),
        t({ "", "    " }), f(function(args) return args[1][1] end, { 1 }), t("->>'"), i(3, "key"), t("' AS text_value,"),
        t({ "", "    " }), f(function(args) return args[1][1] end, { 1 }), t("#>'{"), i(4, "nested,path"), t("}' AS nested_value"),
        t({ "", "FROM " }), i(5, "table_name"),
        t({ "", "WHERE " }), f(function(args) return args[1][1] end, { 1 }), t("->>'"), i(6, "key"), t("' = '"), i(7, "value"), t("';"),
    }),

    -- PostgreSQL ARRAY
    s("arr", {
        t("SELECT * FROM "), i(1, "table_name"),
        t({ "", "WHERE '" }), i(2, "value"), t("' = ANY("), i(3, "array_column"), t(");"),
    }),

    -- Window function
    s("window", {
        t("SELECT"),
        t({ "", "    " }), i(1, "*"), t(","),
        t({ "", "    ROW_NUMBER() OVER (" }),
        t({ "", "        PARTITION BY " }), i(2, "partition_column"),
        t({ "", "        ORDER BY " }), i(3, "order_column"),
        t({ "", "    ) AS row_num" }),
        t({ "", "FROM " }), i(4, "table_name"),
        t(";"),
    }),

    -- Rank function
    s("rank", {
        t("SELECT"),
        t({ "", "    " }), i(1, "*"), t(","),
        t({ "", "    RANK() OVER (ORDER BY " }), i(2, "column"), t(" DESC) AS rank,"),
        t({ "", "    DENSE_RANK() OVER (ORDER BY " }), f(function(args) return args[1][1] end, { 2 }), t(" DESC) AS dense_rank"),
        t({ "", "FROM " }), i(3, "table_name"),
        t(";"),
    }),

    -- ============================================================
    -- GRANT / PERMISSIONS
    -- ============================================================

    -- Grant permissions
    s("grant", {
        t("GRANT "), c(1, { t("SELECT, INSERT, UPDATE, DELETE"), t("ALL PRIVILEGES"), t("SELECT") }),
        t({ "", "ON " }), i(2, "table_name"),
        t({ "", "TO " }), i(3, "user_or_role"),
        t(";"),
    }),

    -- Revoke permissions
    s("revoke", {
        t("REVOKE "), c(1, { t("SELECT, INSERT, UPDATE, DELETE"), t("ALL PRIVILEGES") }),
        t({ "", "ON " }), i(2, "table_name"),
        t({ "", "FROM " }), i(3, "user_or_role"),
        t(";"),
    }),

    -- Create user
    s("crtuser", {
        t("CREATE USER "), i(1, "username"),
        t({ "", "WITH PASSWORD '" }), i(2, "password"), t("';"),
        t({ "", "" }),
        t({ "", "GRANT " }), i(3, "SELECT, INSERT, UPDATE"),
        t({ "", "ON ALL TABLES IN SCHEMA " }), i(4, "public"),
        t({ "", "TO " }), f(function(args) return args[1][1] end, { 1 }),
        t(";"),
    }),
}
