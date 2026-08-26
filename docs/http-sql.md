# REST Client

Test APIs directly in Neovim with `.http` files - no Postman needed.

## Quick Start

Create a file with `.http` extension:
```http
### Get all users
GET http://localhost:8080/api/users
Content-Type: application/json

### Create user
POST http://localhost:8080/api/users
Content-Type: application/json

{
  "name": "John",
  "email": "john@example.com"
}
```

## Keybindings

| Key | Action |
|-----|--------|
| `<leader>rs` | Send request under cursor |
| `<leader>ra` | Send all requests |
| `<leader>rp` | Replay last request |
| `<leader>rc` | Copy as cURL |
| `<leader>rt` | Toggle body/headers view |
| `<leader>re` | Set environment |
| `]r` / `[r` | Jump to next/prev request |

## Commands

| Command | Description |
|---------|-------------|
| `:RestRun` | Run request under cursor |
| `:RestRunAll` | Run all requests in file |
| `:RestCopy` | Copy request as cURL |
| `:RestEnv` | Set environment |

## HTTP Snippets (in .http files)

Comprehensive snippets for API testing - type trigger and press Tab.

### Environment Variables

| Trigger | Description |
|---------|-------------|
| `http-env` | Basic env vars (baseUrl, token, apiKey) |
| `http-env-full` | Full env setup with auth and test IDs |
| `http-var` | Single variable definition |
| `http-ref` | Variable reference `{{var}}` |

**Example usage:**
```http
@baseUrl = http://localhost:8080
@token = your-jwt-token

### Get users
GET {{baseUrl}}/api/users
Authorization: Bearer {{token}}
```

**Or use environment files** (`http-client.env.json`):
```json
{
  "dev": { "baseUrl": "http://localhost:8080" },
  "prod": { "baseUrl": "https://api.example.com" }
}
```
Switch with `<leader>re` or `:RestEnv`.

### GET Requests

| Trigger | Description |
|---------|-------------|
| `http-get` | Basic GET request |
| `http-get-query` | GET with query parameters |
| `http-get-headers` | GET with custom headers |
| `http-get-path` | GET with path parameter |
| `http-get-paginated` | Paginated GET request |

### POST Requests

| Trigger | Description |
|---------|-------------|
| `http-post-json` | POST with JSON body |
| `http-post-json-nested` | POST with nested JSON object |
| `http-post-json-array` | POST with JSON array |
| `http-post-form` | POST with form data |
| `http-post-multipart` | POST multipart/form-data |
| `http-post-xml` | POST with XML body |

### PUT/PATCH/DELETE

| Trigger | Description |
|---------|-------------|
| `http-put-json` | PUT update request |
| `http-patch-json` | PATCH partial update |
| `http-patch-jsonpatch` | JSON Patch format |
| `http-delete` | DELETE request |
| `http-delete-body` | DELETE with body |

### Authentication

| Trigger | Description |
|---------|-------------|
| `http-auth-bearer` | Bearer token auth |
| `http-auth-basic` | Basic auth |
| `http-auth-apikey` | API key header |
| `http-auth-apikey-query` | API key in query string |
| `http-oauth-client-credentials` | OAuth2 client credentials |
| `http-oauth-password` | OAuth2 password grant |
| `http-oauth-refresh` | OAuth2 refresh token |
| `http-jwt-login` | JWT authentication |

### Full Templates

| Trigger | Description |
|---------|-------------|
| `http-crud` | Full CRUD operations template |
| `http-auth-flow` | Complete auth flow (login/refresh/logout) |
| `http-spring-actuator` | Spring Boot Actuator endpoints |
| `http-graphql-query` | GraphQL query template |
| `http-graphql-mutation` | GraphQL mutation template |
| `http-websocket` | WebSocket handshake |
| `http-health` | Simple health check |
| `http-headers-common` | Common headers snippet |

# Database Client

Query MySQL, PostgreSQL, SQLite, and more directly in Neovim.

## Quick Start

```vim
:DBUI                    " Open database UI
:DBUIAddConnection       " Add new connection
```

## Connection Strings

```
mysql://user:password@localhost:3306/dbname
postgresql://user:password@localhost:5432/dbname
sqlite:///path/to/database.db
mongodb://localhost:27017/dbname
```

## Keybindings

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle Database UI |
| `<leader>da` | Add DB connection |
| `<leader>df` | Find DB buffer |
| `<leader>de` | Execute query (normal/visual) |
| `<leader>ds` | Save query |

## Commands

| Command | Description |
|---------|-------------|
| `:DBUI` | Open database UI |
| `:DBUIToggle` | Toggle database UI |
| `:DBUIAddConnection` | Add new connection |
| `:DBUIFindBuffer` | Find DB buffer |

## Features

- Auto-completion for table/column names
- Save and reuse queries
- Browse tables and schemas
- Table helpers (Count, Describe, etc.)

# SQL Snippets (in .sql files)

Comprehensive snippets for database queries - type trigger and press Tab.

## SELECT Queries

| Trigger | Description |
|---------|-------------|
| `sel` | Basic SELECT |
| `sela` | SELECT with table alias |
| `seld` | SELECT DISTINCT |
| `selo` | SELECT with ORDER BY |
| `selp` | SELECT with pagination (LIMIT/OFFSET) |
| `selc` | SELECT COUNT |
| `selg` | SELECT with GROUP BY and HAVING |
| `selagg` | SELECT with aggregations (SUM, AVG, MIN, MAX) |

## JOINs

| Trigger | Description |
|---------|-------------|
| `join` | INNER JOIN |
| `ljoin` | LEFT JOIN |
| `rjoin` | RIGHT JOIN |
| `fjoin` | FULL OUTER JOIN |
| `mjoin` | Multiple JOINs |

## Subqueries & CTEs

| Trigger | Description |
|---------|-------------|
| `selsub` | SELECT with subquery in WHERE |
| `selexists` | SELECT with EXISTS |
| `cte` | Common Table Expression (WITH) |
| `ctem` | Multiple CTEs |

## INSERT/UPDATE/DELETE

| Trigger | Description |
|---------|-------------|
| `ins` | Basic INSERT |
| `insm` | INSERT multiple rows |
| `inssel` | INSERT from SELECT |
| `insret` | INSERT with RETURNING (PostgreSQL) |
| `upsert` | INSERT ON CONFLICT (PostgreSQL) |
| `insig` | INSERT IGNORE (MySQL) |
| `upd` | Basic UPDATE |
| `updm` | UPDATE multiple columns |
| `updj` | UPDATE with JOIN |
| `upds` | UPDATE with subquery |
| `del` | DELETE |
| `delj` | DELETE with JOIN |
| `dels` | DELETE with subquery |
| `trunc` | TRUNCATE TABLE |

## Table Operations

| Trigger | Description |
|---------|-------------|
| `crt` | CREATE TABLE |
| `crtfk` | CREATE TABLE with foreign key |
| `crtfull` | Full CREATE TABLE template |
| `altadd` | ALTER TABLE ADD COLUMN |
| `altdrop` | ALTER TABLE DROP COLUMN |
| `altmod` | ALTER TABLE MODIFY COLUMN |
| `altren` | RENAME COLUMN |
| `altcon` | ADD CONSTRAINT |
| `creidx` | CREATE INDEX |
| `dropidx` | DROP INDEX |

## Transactions & Views

| Trigger | Description |
|---------|-------------|
| `trans` | Transaction block |
| `transsp` | Transaction with savepoint |
| `view` | CREATE VIEW |
| `matview` | CREATE MATERIALIZED VIEW |

## Functions & Triggers

| Trigger | Description |
|---------|-------------|
| `func` | PostgreSQL function |
| `proc` | MySQL stored procedure |
| `trig` | PostgreSQL trigger |

## Utility Queries

| Trigger | Description |
|---------|-------------|
| `dup` | Find duplicates |
| `tinfo` | Table info (columns) |
| `tsize` | Table sizes |
| `runq` | Running queries |
| `killq` | Kill query |
| `expl` | EXPLAIN ANALYZE |
| `case` | CASE statement |
| `coal` | COALESCE |
| `nullif` | NULLIF |
| `datenow` | Current timestamp |
| `dateint` | Date interval |
| `jsonb` | PostgreSQL JSONB queries |
| `arr` | PostgreSQL ARRAY |
| `window` | Window function (ROW_NUMBER) |
| `rank` | RANK/DENSE_RANK |
| `grant` | GRANT permissions |
| `revoke` | REVOKE permissions |
| `crtuser` | CREATE USER with grants |
