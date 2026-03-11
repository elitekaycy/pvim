-- HTTP/REST Client Snippets
-- Comprehensive snippets for backend development
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

-- Helper to get current date
local function date()
    return os.date("%Y-%m-%d")
end

return {
    -- ========================================
    -- ENVIRONMENT VARIABLES
    -- ========================================

    -- File-level variables
    s("http-env", {
        t("# Environment Variables"),
        t({ "", "@baseUrl = " }), i(1, "http://localhost:8080"),
        t({ "", "@token = " }), i(2, "your-token-here"),
        t({ "", "@apiKey = " }), i(3, "your-api-key"),
        t({ "", "" }),
        t({ "", "###" }),
        t({ "", "" }),
    }),

    -- Full environment setup with common vars
    s("http-env-full", {
        t("# ==========================================="),
        t({ "", "# Environment Configuration" }),
        t({ "", "# ===========================================" }),
        t({ "", "" }),
        t({ "", "# Base URL" }),
        t({ "", "@baseUrl = " }), i(1, "http://localhost:8080"),
        t({ "", "" }),
        t({ "", "# Authentication" }),
        t({ "", "@token = " }), i(2, ""),
        t({ "", "@apiKey = " }), i(3, ""),
        t({ "", "@username = " }), i(4, "admin"),
        t({ "", "@password = " }), i(5, "password"),
        t({ "", "" }),
        t({ "", "# Common IDs for testing" }),
        t({ "", "@userId = " }), i(6, "1"),
        t({ "", "@resourceId = " }), i(7, "1"),
        t({ "", "" }),
        t({ "", "# ===========================================" }),
        t({ "", "" }),
    }),

    -- Single variable
    s("http-var", {
        t("@"), i(1, "variableName"), t(" = "), i(2, "value"),
    }),

    -- Variable reference
    s("http-ref", {
        t("{{"), i(1, "variableName"), t("}}"),
    }),

    -- ========================================
    -- GET REQUESTS
    -- ========================================

    -- Basic GET
    s("http-get", {
        t("### "), i(1, "Get Request"),
        t({ "", "GET " }), i(2, "{{baseUrl}}/api/endpoint"),
        t({ "", "" }),
    }),

    -- GET with query parameters
    s("http-get-query", {
        t("### "), i(1, "Get with Query Params"),
        t({ "", "GET " }), i(2, "{{baseUrl}}/api/endpoint"), t("?"),
        i(3, "page"), t("="), i(4, "1"), t("&"),
        i(5, "limit"), t("="), i(6, "10"), t("&"),
        i(7, "sort"), t("="), i(8, "createdAt:desc"),
        t({ "", "" }),
    }),

    -- GET with headers
    s("http-get-headers", {
        t("### "), i(1, "Get with Headers"),
        t({ "", "GET " }), i(2, "{{baseUrl}}/api/endpoint"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "Accept: application/json" }),
        t({ "", "X-Request-ID: " }), i(3, "{{$uuid}}"),
        t({ "", "" }),
    }),

    -- GET with path parameter
    s("http-get-path", {
        t("### "), i(1, "Get by ID"),
        t({ "", "GET " }), i(2, "{{baseUrl}}/api/"), i(3, "users"), t("/"), i(4, "{{id}}"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "" }),
    }),

    -- GET with pagination
    s("http-get-paginated", {
        t("### "), i(1, "Get Paginated List"),
        t({ "", "GET " }), i(2, "{{baseUrl}}/api/"), i(3, "items"),
        t("?page={{page}}&size={{size}}&sort="), i(4, "id"), t(","), i(5, "desc"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "" }),
    }),

    -- ========================================
    -- POST REQUESTS
    -- ========================================

    -- POST with JSON body
    s("http-post-json", {
        t("### "), i(1, "Create Resource"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/api/endpoint"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{" }),
        t({ "", '  "' }), i(3, "name"), t('": "'), i(4, "value"), t('",'),
        t({ "", '  "' }), i(5, "email"), t('": "'), i(6, "user@example.com"), t('"'),
        t({ "", "}", "" }),
    }),

    -- POST with nested JSON
    s("http-post-json-nested", {
        t("### "), i(1, "Create with Nested Object"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/api/endpoint"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{" }),
        t({ "", '  "' }), i(3, "name"), t('": "'), i(4, "value"), t('",'),
        t({ "", '  "' }), i(5, "metadata"), t('": {'),
        t({ "", '    "' }), i(6, "key"), t('": "'), i(7, "value"), t('"'),
        t({ "", "  }," }),
        t({ "", '  "' }), i(8, "tags"), t('": ["'), i(9, "tag1"), t('", "'), i(10, "tag2"), t('"]'),
        t({ "", "}", "" }),
    }),

    -- POST with array body
    s("http-post-json-array", {
        t("### "), i(1, "Create Multiple"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/api/endpoint/batch"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "[" }),
        t({ "", "  {" }),
        t({ "", '    "' }), i(3, "name"), t('": "'), i(4, "item1"), t('"'),
        t({ "", "  }," }),
        t({ "", "  {" }),
        t({ "", '    "' }), i(5, "name"), t('": "'), i(6, "item2"), t('"'),
        t({ "", "  }" }),
        t({ "", "]", "" }),
    }),

    -- POST form urlencoded
    s("http-post-form", {
        t("### "), i(1, "Form Submit"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/api/endpoint"),
        t({ "", "Content-Type: application/x-www-form-urlencoded" }),
        t({ "", "" }),
        i(3, "username"), t("="), i(4, "user"), t("&"),
        i(5, "password"), t("="), i(6, "pass"),
        t({ "", "" }),
    }),

    -- POST multipart form (file upload)
    s("http-post-multipart", {
        t("### "), i(1, "File Upload"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/api/upload"),
        t({ "", "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary" }),
        t({ "", "" }),
        t({ "", "------WebKitFormBoundary" }),
        t({ "", 'Content-Disposition: form-data; name="' }), i(3, "file"), t('"; filename="'), i(4, "example.txt"), t('"'),
        t({ "", "Content-Type: " }), i(5, "text/plain"),
        t({ "", "" }),
        t({ "", "< " }), i(6, "./path/to/file.txt"),
        t({ "", "------WebKitFormBoundary--", "" }),
    }),

    -- POST XML body
    s("http-post-xml", {
        t("### "), i(1, "Create XML"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/api/endpoint"),
        t({ "", "Content-Type: application/xml" }),
        t({ "", "" }),
        t({ "", "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" }),
        t({ "", "<" }), i(3, "root"), t(">"),
        t({ "", "  <" }), i(4, "element"), t(">"), i(5, "value"), t("</"), f(function(args) return args[1][1] end, {4}), t(">"),
        t({ "", "</" }), f(function(args) return args[1][1] end, {3}), t(">"),
        t({ "", "" }),
    }),

    -- ========================================
    -- PUT/PATCH REQUESTS
    -- ========================================

    -- PUT (full update)
    s("http-put-json", {
        t("### "), i(1, "Update Resource"),
        t({ "", "PUT " }), i(2, "{{baseUrl}}/api/"), i(3, "users"), t("/"), i(4, "{{id}}"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{" }),
        t({ "", '  "id": ' }), i(5, "{{id}}"), t(","),
        t({ "", '  "' }), i(6, "name"), t('": "'), i(7, "updated value"), t('",'),
        t({ "", '  "' }), i(8, "email"), t('": "'), i(9, "updated@example.com"), t('"'),
        t({ "", "}", "" }),
    }),

    -- PATCH (partial update)
    s("http-patch-json", {
        t("### "), i(1, "Partial Update"),
        t({ "", "PATCH " }), i(2, "{{baseUrl}}/api/"), i(3, "users"), t("/"), i(4, "{{id}}"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{" }),
        t({ "", '  "' }), i(5, "field"), t('": "'), i(6, "new value"), t('"'),
        t({ "", "}", "" }),
    }),

    -- JSON Patch format
    s("http-patch-jsonpatch", {
        t("### "), i(1, "JSON Patch"),
        t({ "", "PATCH " }), i(2, "{{baseUrl}}/api/"), i(3, "users"), t("/"), i(4, "{{id}}"),
        t({ "", "Content-Type: application/json-patch+json" }),
        t({ "", "", "[" }),
        t({ "", '  { "op": "' }), i(5, "replace"), t('", "path": "/'), i(6, "name"), t('", "value": "'), i(7, "new value"), t('" }'),
        t({ "", "]", "" }),
    }),

    -- ========================================
    -- DELETE REQUESTS
    -- ========================================

    -- Basic DELETE
    s("http-delete", {
        t("### "), i(1, "Delete Resource"),
        t({ "", "DELETE " }), i(2, "{{baseUrl}}/api/"), i(3, "users"), t("/"), i(4, "{{id}}"),
        t({ "", "" }),
    }),

    -- DELETE with body
    s("http-delete-body", {
        t("### "), i(1, "Delete with Body"),
        t({ "", "DELETE " }), i(2, "{{baseUrl}}/api/"), i(3, "users"), t("/batch"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{" }),
        t({ "", '  "ids": [' }), i(4, "1, 2, 3"), t("]"),
        t({ "", "}", "" }),
    }),

    -- ========================================
    -- AUTHENTICATION
    -- ========================================

    -- Bearer Token
    s("http-auth-bearer", {
        t("Authorization: Bearer "), i(1, "{{token}}"),
        t({ "", "" }),
    }),

    -- Basic Auth
    s("http-auth-basic", {
        t("Authorization: Basic "), i(1, "{{base64(username:password)}}"),
        t({ "", "" }),
    }),

    -- API Key header
    s("http-auth-apikey", {
        t("X-API-Key: "), i(1, "{{apiKey}}"),
        t({ "", "" }),
    }),

    -- API Key query param
    s("http-auth-apikey-query", {
        t("?api_key="), i(1, "{{apiKey}}"),
    }),

    -- OAuth2 Token Request (Client Credentials)
    s("http-oauth-client-credentials", {
        t("### OAuth2 - Client Credentials"),
        t({ "", "POST " }), i(1, "{{authUrl}}/oauth/token"),
        t({ "", "Content-Type: application/x-www-form-urlencoded" }),
        t({ "", "" }),
        t("grant_type=client_credentials"),
        t("&client_id="), i(2, "{{clientId}}"),
        t("&client_secret="), i(3, "{{clientSecret}}"),
        t("&scope="), i(4, "read write"),
        t({ "", "" }),
    }),

    -- OAuth2 Token Request (Password Grant)
    s("http-oauth-password", {
        t("### OAuth2 - Password Grant"),
        t({ "", "POST " }), i(1, "{{authUrl}}/oauth/token"),
        t({ "", "Content-Type: application/x-www-form-urlencoded" }),
        t({ "", "" }),
        t("grant_type=password"),
        t("&client_id="), i(2, "{{clientId}}"),
        t("&client_secret="), i(3, "{{clientSecret}}"),
        t("&username="), i(4, "{{username}}"),
        t("&password="), i(5, "{{password}}"),
        t({ "", "" }),
    }),

    -- OAuth2 Refresh Token
    s("http-oauth-refresh", {
        t("### OAuth2 - Refresh Token"),
        t({ "", "POST " }), i(1, "{{authUrl}}/oauth/token"),
        t({ "", "Content-Type: application/x-www-form-urlencoded" }),
        t({ "", "" }),
        t("grant_type=refresh_token"),
        t("&client_id="), i(2, "{{clientId}}"),
        t("&client_secret="), i(3, "{{clientSecret}}"),
        t("&refresh_token="), i(4, "{{refreshToken}}"),
        t({ "", "" }),
    }),

    -- JWT Login
    s("http-jwt-login", {
        t("### JWT Login"),
        t({ "", "POST " }), i(1, "{{baseUrl}}/api/auth/login"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{" }),
        t({ "", '  "username": "' }), i(2, "{{username}}"), t('",'),
        t({ "", '  "password": "' }), i(3, "{{password}}"), t('"'),
        t({ "", "}", "" }),
    }),

    -- ========================================
    -- VARIABLES & ENVIRONMENT
    -- ========================================

    -- Variable definition
    s("http-var", {
        t("@"), i(1, "variable"), t(" = "), i(2, "value"),
        t({ "", "" }),
    }),

    -- Environment variables block
    s("http-env", {
        t("### Environment Variables"),
        t({ "", "@baseUrl = " }), i(1, "http://localhost:8080"),
        t({ "", "@apiVersion = " }), i(2, "v1"),
        t({ "", "@token = " }), i(3, "your-token-here"),
        t({ "", "" }),
    }),

    -- ========================================
    -- FULL TEMPLATES
    -- ========================================

    -- Complete CRUD API
    s("http-crud", {
        t("### "), i(1, "Resource"), t(" API"),
        t({ "", "### Variables" }),
        t({ "", "@baseUrl = " }), i(2, "http://localhost:8080"),
        t({ "", "@resource = " }), i(3, "users"),
        t({ "", "@id = 1" }),
        t({ "", "" }),

        t({ "", "### Get All" }),
        t({ "", "GET {{baseUrl}}/api/{{resource}}" }),
        t({ "", "Content-Type: application/json" }),
        t({ "", "" }),

        t({ "", "### Get by ID" }),
        t({ "", "GET {{baseUrl}}/api/{{resource}}/{{id}}" }),
        t({ "", "Content-Type: application/json" }),
        t({ "", "" }),

        t({ "", "### Create" }),
        t({ "", "POST {{baseUrl}}/api/{{resource}}" }),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{", '  "name": "New Item"', "}" }),
        t({ "", "" }),

        t({ "", "### Update" }),
        t({ "", "PUT {{baseUrl}}/api/{{resource}}/{{id}}" }),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{", '  "id": {{id}},', '  "name": "Updated Item"', "}" }),
        t({ "", "" }),

        t({ "", "### Delete" }),
        t({ "", "DELETE {{baseUrl}}/api/{{resource}}/{{id}}" }),
        t({ "", "" }),
    }),

    -- Auth + Protected Request
    s("http-auth-flow", {
        t("### Authentication Flow"),
        t({ "", "" }),
        t({ "", "@baseUrl = " }), i(1, "http://localhost:8080"),
        t({ "", "@authUrl = " }), i(2, "http://localhost:8080/auth"),
        t({ "", "" }),

        t({ "", "### 1. Login" }),
        t({ "", "# @name login" }),
        t({ "", "POST {{authUrl}}/login" }),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{", '  "username": "admin",', '  "password": "admin123"', "}" }),
        t({ "", "" }),

        t({ "", "### 2. Use Token" }),
        t({ "", "GET {{baseUrl}}/api/protected" }),
        t({ "", "Authorization: Bearer {{login.response.body.token}}" }),
        t({ "", "" }),
    }),

    -- Spring Boot Actuator
    s("http-spring-actuator", {
        t("### Spring Boot Actuator"),
        t({ "", "" }),
        t({ "", "@baseUrl = " }), i(1, "http://localhost:8080"),
        t({ "", "" }),

        t({ "", "### Health Check" }),
        t({ "", "GET {{baseUrl}}/actuator/health" }),
        t({ "", "" }),

        t({ "", "### Info" }),
        t({ "", "GET {{baseUrl}}/actuator/info" }),
        t({ "", "" }),

        t({ "", "### Metrics" }),
        t({ "", "GET {{baseUrl}}/actuator/metrics" }),
        t({ "", "" }),

        t({ "", "### Env" }),
        t({ "", "GET {{baseUrl}}/actuator/env" }),
        t({ "", "" }),

        t({ "", "### Loggers" }),
        t({ "", "GET {{baseUrl}}/actuator/loggers" }),
        t({ "", "" }),

        t({ "", "### Change Log Level" }),
        t({ "", "POST {{baseUrl}}/actuator/loggers/com.example" }),
        t({ "", "Content-Type: application/json" }),
        t({ "", "", "{", '  "configuredLevel": "DEBUG"', "}" }),
        t({ "", "" }),
    }),

    -- GraphQL
    s("http-graphql-query", {
        t("### "), i(1, "GraphQL Query"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/graphql"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "" }),
        t({ "", "{" }),
        t({ "", '  "query": "query { ' }), i(3, "users"), t(" { "), i(4, "id name email"), t(' }"'),
        t({ "", "}" }),
        t({ "", "" }),
    }),

    s("http-graphql-mutation", {
        t("### "), i(1, "GraphQL Mutation"),
        t({ "", "POST " }), i(2, "{{baseUrl}}/graphql"),
        t({ "", "Content-Type: application/json" }),
        t({ "", "" }),
        t({ "", "{" }),
        t({ "", '  "query": "mutation { create' }), i(3, "User"), t("(input: { "), i(4, 'name: \\"John\\"'), t(" }) { "), i(5, "id name"), t(' }}"'),
        t({ "", "}" }),
        t({ "", "" }),
    }),

    -- WebSocket (upgrade request)
    s("http-websocket", {
        t("### WebSocket Upgrade"),
        t({ "", "GET " }), i(1, "{{baseUrl}}/ws"),
        t({ "", "Connection: Upgrade" }),
        t({ "", "Upgrade: websocket" }),
        t({ "", "Sec-WebSocket-Version: 13" }),
        t({ "", "Sec-WebSocket-Key: " }), i(2, "{{$uuid}}"),
        t({ "", "" }),
    }),

    -- Health check
    s("http-health", {
        t("### Health Check"),
        t({ "", "GET " }), i(1, "{{baseUrl}}"), t("/health"),
        t({ "", "" }),
    }),

    -- Common headers block
    s("http-headers-common", {
        t("Content-Type: application/json"),
        t({ "", "Accept: application/json" }),
        t({ "", "Accept-Language: en-US" }),
        t({ "", "X-Request-ID: {{$uuid}}" }),
        t({ "", "X-Correlation-ID: {{$uuid}}" }),
        t({ "", "" }),
    }),
}
