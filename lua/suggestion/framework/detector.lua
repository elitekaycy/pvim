-- Framework Detector
-- Detects project framework from build files and structure
local M = {}

local Path = require("plenary.path")

---@class FrameworkInfo
---@field id string Framework identifier
---@field name string Human-readable name
---@field language string Primary language
---@field version string|nil Detected version

-- Build file patterns for Java frameworks
local JAVA_FRAMEWORK_PATTERNS = {
    {
        id = "spring_boot",
        name = "Spring Boot",
        markers = { "spring-boot-starter", "org.springframework.boot" },
        files = { "pom.xml", "build.gradle", "build.gradle.kts" },
    },
    {
        id = "spring_webflux",
        name = "Spring WebFlux",
        markers = { "spring-boot-starter-webflux", "spring-webflux" },
        files = { "pom.xml", "build.gradle", "build.gradle.kts" },
    },
    {
        id = "quarkus",
        name = "Quarkus",
        markers = { "io.quarkus", "quarkus-" },
        files = { "pom.xml", "build.gradle", "build.gradle.kts" },
    },
    {
        id = "micronaut",
        name = "Micronaut",
        markers = { "io.micronaut", "micronaut-" },
        files = { "pom.xml", "build.gradle", "build.gradle.kts" },
    },
    {
        id = "jakarta_ee",
        name = "Jakarta EE",
        markers = { "jakarta.platform", "jakarta.jakartaee-api" },
        files = { "pom.xml", "build.gradle", "build.gradle.kts" },
    },
}

-- Build file patterns for TypeScript/JavaScript frameworks
local TS_FRAMEWORK_PATTERNS = {
    {
        id = "nextjs",
        name = "Next.js",
        markers = { '"next":', "'next':" },
        files = { "package.json" },
    },
    {
        id = "react",
        name = "React",
        markers = { '"react":', "'react':" },
        files = { "package.json" },
    },
    {
        id = "angular",
        name = "Angular",
        markers = { '"@angular/core":', "'@angular/core':" },
        files = { "package.json" },
    },
    {
        id = "vue",
        name = "Vue.js",
        markers = { '"vue":', "'vue':" },
        files = { "package.json" },
    },
    {
        id = "express",
        name = "Express",
        markers = { '"express":', "'express':" },
        files = { "package.json" },
    },
    {
        id = "nestjs",
        name = "NestJS",
        markers = { '"@nestjs/core":', "'@nestjs/core':" },
        files = { "package.json" },
    },
}

---Read file content if it exists
---@param filepath string
---@return string|nil
local function read_file(filepath)
    local path = Path:new(filepath)
    if path:exists() then
        local ok, content = pcall(function()
            return path:read()
        end)
        if ok then
            return content
        end
    end
    return nil
end

---Detect Java framework from build files
---@param project_root string
---@return FrameworkInfo|nil
local function detect_java_framework(project_root)
    for _, framework in ipairs(JAVA_FRAMEWORK_PATTERNS) do
        for _, file in ipairs(framework.files) do
            local filepath = project_root .. "/" .. file
            local content = read_file(filepath)

            if content then
                for _, marker in ipairs(framework.markers) do
                    if content:find(marker, 1, true) then
                        return {
                            id = framework.id,
                            name = framework.name,
                            language = "java",
                            version = nil,
                        }
                    end
                end
            end
        end
    end

    -- Check for plain Java project (has pom.xml or build.gradle but no framework)
    if read_file(project_root .. "/pom.xml") or
       read_file(project_root .. "/build.gradle") or
       read_file(project_root .. "/build.gradle.kts") then
        return {
            id = "plain_java",
            name = "Java",
            language = "java",
            version = nil,
        }
    end

    return nil
end

---Detect TypeScript/JavaScript framework from package.json
---@param project_root string
---@return FrameworkInfo|nil
local function detect_ts_framework(project_root)
    local package_json = read_file(project_root .. "/package.json")
    if not package_json then
        return nil
    end

    for _, framework in ipairs(TS_FRAMEWORK_PATTERNS) do
        for _, marker in ipairs(framework.markers) do
            if package_json:find(marker, 1, true) then
                return {
                    id = framework.id,
                    name = framework.name,
                    language = "typescript",
                    version = nil,
                }
            end
        end
    end

    -- Plain TypeScript/JavaScript project
    if package_json:find('"typescript":', 1, true) then
        return {
            id = "plain_typescript",
            name = "TypeScript",
            language = "typescript",
            version = nil,
        }
    end

    return {
        id = "plain_javascript",
        name = "JavaScript",
        language = "javascript",
        version = nil,
    }
end

---Detect framework for a project
---@param project_root string Project root directory
---@return FrameworkInfo|nil
function M.detect(project_root)
    if not project_root or project_root == "" then
        return nil
    end

    -- Try Java first
    local java_framework = detect_java_framework(project_root)
    if java_framework then
        return java_framework
    end

    -- Try TypeScript/JavaScript
    local ts_framework = detect_ts_framework(project_root)
    if ts_framework then
        return ts_framework
    end

    return nil
end

---Get framework from filetype
---@param ft string Filetype
---@param project_root string Project root
---@return FrameworkInfo|nil
function M.detect_for_filetype(ft, project_root)
    local detected = M.detect(project_root)

    -- Match language to filetype
    if detected then
        if ft == "java" and detected.language == "java" then
            return detected
        elseif (ft == "typescript" or ft == "typescriptreact" or
                ft == "javascript" or ft == "javascriptreact") and
               (detected.language == "typescript" or detected.language == "javascript") then
            return detected
        end
    end

    -- Return default based on filetype
    if ft == "java" then
        return {
            id = "plain_java",
            name = "Java",
            language = "java",
            version = nil,
        }
    elseif ft == "typescript" or ft == "typescriptreact" then
        return {
            id = "plain_typescript",
            name = "TypeScript",
            language = "typescript",
            version = nil,
        }
    elseif ft == "javascript" or ft == "javascriptreact" then
        return {
            id = "plain_javascript",
            name = "JavaScript",
            language = "javascript",
            version = nil,
        }
    end

    return nil
end

return M
