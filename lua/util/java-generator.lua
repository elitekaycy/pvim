-- Java module generator - creates complete CRUD modules
local M = {}

local project = require("util.java-project")

-- Templates for each file type
local templates = {}

templates.entity = [[
package {pkg}.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "{table}")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class {entity} implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
]]

templates.dto = [[
package {pkg}.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {entity}Dto {

    private Long id;
}
]]

templates.repository = [[
package {pkg}.repository;

import {pkg}.entity.{entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface {entity}Repository extends JpaRepository<{entity}, Long> {

    Optional<{entity}> findByName(String name);

    boolean existsByName(String name);
}
]]

templates.mapper = [[
package {pkg}.mapper;

import {pkg}.dto.{entity}Dto;
import {pkg}.entity.{entity};
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface {entity}Mapper {

    {entity}Dto toDto({entity} entity);

    {entity} toEntity({entity}Dto dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity({entity}Dto dto, @MappingTarget {entity} entity);
}
]]

templates.service = [[
package {pkg}.service;

import {pkg}.dto.{entity}Dto;
import {pkg}.entity.{entity};
import {pkg}.mapper.{entity}Mapper;
import {pkg}.repository.{entity}Repository;
import {pkg}.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class {entity}Service {

    private final {entity}Repository {entity_var}Repository;
    private final {entity}Mapper {entity_var}Mapper;

    @Transactional(readOnly = true)
    public List<{entity}Dto> findAll() {
        log.debug("Finding all {entity}s");
        return {entity_var}Repository.findAll().stream()
                .map({entity_var}Mapper::toDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public {entity}Dto findById(Long id) {
        log.debug("Finding {entity} by id: {}", id);
        return {entity_var}Repository.findById(id)
                .map({entity_var}Mapper::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("{entity} not found: " + id));
    }

    public {entity}Dto create({entity}Dto dto) {
        log.info("Creating {entity}");
        {entity} entity = {entity_var}Mapper.toEntity(dto);
        return {entity_var}Mapper.toDto({entity_var}Repository.save(entity));
    }

    public {entity}Dto update(Long id, {entity}Dto dto) {
        log.info("Updating {entity}: {}", id);
        {entity} entity = {entity_var}Repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("{entity} not found: " + id));
        {entity_var}Mapper.updateEntity(dto, entity);
        return {entity_var}Mapper.toDto({entity_var}Repository.save(entity));
    }

    public void delete(Long id) {
        log.info("Deleting {entity}: {}", id);
        if (!{entity_var}Repository.existsById(id)) {
            throw new ResourceNotFoundException("{entity} not found: " + id);
        }
        {entity_var}Repository.deleteById(id);
    }
}
]]

templates.controller = [[
package {pkg}.controller;

import {pkg}.dto.{entity}Dto;
import {pkg}.service.{entity}Service;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/{endpoint}")
@RequiredArgsConstructor
public class {entity}Controller {

    private final {entity}Service {entity_var}Service;

    @GetMapping
    public ResponseEntity<List<{entity}Dto>> getAll() {
        return ResponseEntity.ok({entity_var}Service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<{entity}Dto> getById(@PathVariable Long id) {
        return ResponseEntity.ok({entity_var}Service.findById(id));
    }

    @PostMapping
    public ResponseEntity<{entity}Dto> create(@Valid @RequestBody {entity}Dto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body({entity_var}Service.create(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<{entity}Dto> update(@PathVariable Long id, @Valid @RequestBody {entity}Dto dto) {
        return ResponseEntity.ok({entity_var}Service.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        {entity_var}Service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
]]

templates.exception = [[
package {pkg}.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String message) {
        super(message);
    }

    public ResourceNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
]]

templates.test_service = [[
package {pkg}.service;

import {pkg}.dto.{entity}Dto;
import {pkg}.entity.{entity};
import {pkg}.mapper.{entity}Mapper;
import {pkg}.repository.{entity}Repository;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class {entity}ServiceTest {

    @Mock
    private {entity}Repository {entity_var}Repository;

    @Mock
    private {entity}Mapper {entity_var}Mapper;

    @InjectMocks
    private {entity}Service underTest;

    @Test
    @DisplayName("should find all")
    void shouldFindAll() {
        // Given
        {entity} entity = {entity}.builder().id(1L).build();
        {entity}Dto dto = {entity}Dto.builder().id(1L).build();
        when({entity_var}Repository.findAll()).thenReturn(List.of(entity));
        when({entity_var}Mapper.toDto(entity)).thenReturn(dto);

        // When
        List<{entity}Dto> result = underTest.findAll();

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("should find by id")
    void shouldFindById() {
        // Given
        {entity} entity = {entity}.builder().id(1L).build();
        {entity}Dto dto = {entity}Dto.builder().id(1L).build();
        when({entity_var}Repository.findById(1L)).thenReturn(Optional.of(entity));
        when({entity_var}Mapper.toDto(entity)).thenReturn(dto);

        // When
        {entity}Dto result = underTest.findById(1L);

        // Then
        assertThat(result.getId()).isEqualTo(1L);
    }
}
]]

--- Pluralize a word (simple)
---@param word string
---@return string
local function pluralize(word)
    local lower = word:lower()
    if lower:sub(-1) == "s" or lower:sub(-1) == "x" or lower:sub(-2) == "ch" or lower:sub(-2) == "sh" then
        return lower .. "es"
    elseif lower:sub(-1) == "y" and not lower:sub(-2, -2):match("[aeiou]") then
        return lower:sub(1, -2) .. "ies"
    else
        return lower .. "s"
    end
end

--- Lowercase first letter
---@param str string
---@return string
local function lcfirst(str)
    return str:sub(1, 1):lower() .. str:sub(2)
end

--- Apply template with replacements
---@param template string
---@param entity string
---@param pkg string
---@return string
local function apply_template(template, entity, pkg)
    local replacements = {
        ["{entity}"] = entity,
        ["{entity_var}"] = lcfirst(entity),
        ["{table}"] = pluralize(entity),
        ["{endpoint}"] = pluralize(entity),
        ["{pkg}"] = pkg,
    }

    local result = template
    for pattern, replacement in pairs(replacements) do
        result = result:gsub(pattern:gsub("[{}]", "%%%1"), replacement)
    end
    return result
end

--- Generate a single file
---@param entity string
---@param file_type string
---@param overwrite boolean
---@return string|nil filepath, string|nil error
function M.generate_file(entity, file_type, overwrite)
    local structure = project.get_structure()
    if not structure then
        return nil, "No project structure found"
    end

    local template = templates[file_type]
    if not template then
        return nil, "Unknown file type: " .. file_type
    end

    -- Determine path and filename
    local pkg_type = file_type
    local filename = entity
    local is_test = false

    if file_type == "test_service" then
        pkg_type = "service"
        filename = entity .. "ServiceTest"
        is_test = true
    elseif file_type == "dto" then
        filename = entity .. "Dto"
    elseif file_type == "repository" then
        filename = entity .. "Repository"
    elseif file_type == "mapper" then
        filename = entity .. "Mapper"
    elseif file_type == "service" then
        filename = entity .. "Service"
    elseif file_type == "controller" then
        filename = entity .. "Controller"
    end

    local base_path
    if is_test then
        base_path = structure.src_test .. "/" .. structure.base_package:gsub("%.", "/")
    else
        base_path = structure.src_main .. "/" .. structure.base_package:gsub("%.", "/")
    end

    local dir_path = base_path .. "/" .. pkg_type
    local file_path = dir_path .. "/" .. filename .. ".java"

    -- Check if file exists
    if not overwrite and vim.fn.filereadable(file_path) == 1 then
        return nil, "File already exists: " .. file_path
    end

    -- Ensure directory exists
    project.ensure_dir(dir_path)

    -- Generate content
    local content = apply_template(template, entity, structure.base_package)

    -- Write file
    local file = io.open(file_path, "w")
    if not file then
        return nil, "Failed to write file: " .. file_path
    end
    file:write(content)
    file:close()

    return file_path, nil
end

--- Generate complete CRUD module
---@param entity string
---@param options table|nil { overwrite: boolean, skip: string[], include_tests: boolean }
---@return table results
function M.generate_module(entity, options)
    options = options or {}
    local overwrite = options.overwrite or false
    local skip = options.skip or {}
    local include_tests = options.include_tests ~= false

    -- Build skip set
    local skip_set = {}
    for _, s in ipairs(skip) do
        skip_set[s] = true
    end

    local file_types = { "entity", "dto", "repository", "mapper", "service", "controller" }
    if include_tests then
        table.insert(file_types, "test_service")
    end

    -- Check if exception exists, create if not
    local structure = project.get_structure()
    if structure then
        local exception_path = structure.src_main .. "/" .. structure.base_package:gsub("%.", "/") .. "/exception/ResourceNotFoundException.java"
        if vim.fn.filereadable(exception_path) == 0 then
            M.generate_file("Resource", "exception", false)
        end
    end

    local results = {
        created = {},
        skipped = {},
        errors = {},
    }

    for _, file_type in ipairs(file_types) do
        if not skip_set[file_type] then
            local path, err = M.generate_file(entity, file_type, overwrite)
            if path then
                table.insert(results.created, { type = file_type, path = path })
            elseif err and err:match("already exists") then
                table.insert(results.skipped, { type = file_type, reason = err })
            else
                table.insert(results.errors, { type = file_type, error = err })
            end
        else
            table.insert(results.skipped, { type = file_type, reason = "skipped by user" })
        end
    end

    return results
end

--- Print generation results
---@param results table
function M.print_results(results)
    if #results.created > 0 then
        print("Created files:")
        for _, item in ipairs(results.created) do
            print("  ✓ " .. item.type .. ": " .. item.path)
        end
    end

    if #results.skipped > 0 then
        print("Skipped:")
        for _, item in ipairs(results.skipped) do
            print("  - " .. item.type .. ": " .. item.reason)
        end
    end

    if #results.errors > 0 then
        print("Errors:")
        for _, item in ipairs(results.errors) do
            print("  ✗ " .. item.type .. ": " .. item.error)
        end
    end
end

--- Interactive module creation with Telescope
function M.create_module_interactive()
    vim.ui.input({ prompt = "Entity name (e.g., User, Product): " }, function(entity)
        if not entity or entity == "" then
            print("Cancelled")
            return
        end

        -- Capitalize first letter
        entity = entity:sub(1, 1):upper() .. entity:sub(2)

        local results = M.generate_module(entity)
        M.print_results(results)

        -- Open the entity file
        if #results.created > 0 then
            for _, item in ipairs(results.created) do
                if item.type == "entity" then
                    vim.cmd("edit " .. item.path)
                    break
                end
            end
        end
    end)
end

--- Quick create just entity + dto + repository
---@param entity string
function M.generate_basic(entity)
    return M.generate_module(entity, {
        skip = { "mapper", "service", "controller", "test_service" },
    })
end

return M
