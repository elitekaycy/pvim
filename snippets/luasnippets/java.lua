-- Dynamic Java/Spring Boot snippets with project context awareness
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

-- Load Java context helper
local java_ctx = require("util.java-context")

-- Helper function nodes
local function get_package()
    return java_ctx.get_package()
end

local function get_class_name()
    return java_ctx.get_class_name()
end

local function get_base_package()
    return java_ctx.get_base_package()
end

-- ============================================================================
-- ENTITY SNIPPETS
-- ============================================================================

ls.add_snippets("java", {
    -- Dynamic Entity
    s("spring_entity_ctx", fmt([[
package {};

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "{}")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class {} {{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    {}

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {{
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }}

    @PreUpdate
    protected void onUpdate() {{
        updatedAt = LocalDateTime.now();
    }}
}}
]], {
        f(function() return get_package() end),
        i(1, "table_name"),
        f(function() return get_class_name() end),
        i(0),
    })),

    -- Dynamic DTO
    s("spring_dto_ctx", fmt([[
package {}.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class {}DTO {{
    {}
}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_class_name():gsub("DTO$", "") end),
        i(0),
    })),

    -- Dynamic Record DTO
    s("spring_record_ctx", fmt([[
package {}.dto;

public record {}(
    {}
) {{}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_class_name() end),
        i(0),
    })),

    -- Dynamic Controller
    s("spring_controller_ctx", fmt([[
package {}.controller;

import {}.dto.*;
import {}.service.{}Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/{}")
@RequiredArgsConstructor
public class {}Controller {{

    private final {}Service {}Service;

    @GetMapping
    public ResponseEntity<List<{}DTO>> getAll() {{
        return ResponseEntity.ok({}Service.findAll());
    }}

    @GetMapping("/{id}")
    public ResponseEntity<{}DTO> getById(@PathVariable Long id) {{
        return ResponseEntity.ok({}Service.findById(id));
    }}

    @PostMapping
    public ResponseEntity<{}DTO> create(@RequestBody {}DTO dto) {{
        return ResponseEntity.ok({}Service.create(dto));
    }}

    @PutMapping("/{id}")
    public ResponseEntity<{}DTO> update(@PathVariable Long id, @RequestBody {}DTO dto) {{
        return ResponseEntity.ok({}Service.update(id, dto));
    }}

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {{
        {}Service.delete(id);
        return ResponseEntity.noContent().build();
    }}
}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_base_package() end),
        f(function() return get_base_package() end),
        i(1, "Entity"),
        i(2, "entities"),
        rep(1),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
    })),

    -- Dynamic Service
    s("spring_service_ctx", fmt([[
package {}.service;

import {}.dto.{}DTO;
import {}.entity.{};
import {}.repository.{}Repository;
import {}.mapper.{}Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class {}Service {{

    private final {}Repository {}Repository;
    private final {}Mapper {}Mapper;

    public List<{}DTO> findAll() {{
        return {}Repository.findAll().stream()
            .map({}Mapper::toDto)
            .toList();
    }}

    public {}DTO findById(Long id) {{
        return {}Repository.findById(id)
            .map({}Mapper::toDto)
            .orElseThrow(() -> new RuntimeException("{} not found with id: " + id));
    }}

    @Transactional
    public {}DTO create({}DTO dto) {{
        {} entity = {}Mapper.toEntity(dto);
        return {}Mapper.toDto({}Repository.save(entity));
    }}

    @Transactional
    public {}DTO update(Long id, {}DTO dto) {{
        {} entity = {}Repository.findById(id)
            .orElseThrow(() -> new RuntimeException("{} not found with id: " + id));
        {}Mapper.updateEntity(entity, dto);
        return {}Mapper.toDto({}Repository.save(entity));
    }}

    @Transactional
    public void delete(Long id) {{
        {}Repository.deleteById(id);
    }}
}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_base_package() end), i(1, "Entity"),
        f(function() return get_base_package() end), rep(1),
        f(function() return get_base_package() end), rep(1),
        f(function() return get_base_package() end), rep(1),
        rep(1),
        rep(1), f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1), f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        rep(1), rep(1),
        rep(1), f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1), rep(1),
        rep(1), f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        rep(1),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
        f(function(args) return args[1][1]:sub(1,1):lower() .. args[1][1]:sub(2) end, {1}),
    })),

    -- Dynamic Repository
    s("spring_repository_ctx", fmt([[
package {}.repository;

import {}.entity.{};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface {}Repository extends JpaRepository<{}, Long> {{
    {}
}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_base_package() end),
        i(1, "Entity"),
        rep(1),
        rep(1),
        i(0),
    })),

    -- Dynamic Mapper
    s("spring_mapper_ctx", fmt([[
package {}.mapper;

import {}.dto.{}DTO;
import {}.entity.{};
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface {}Mapper {{

    {}DTO toDto({} entity);

    @Mapping(target = "id", ignore = true)
    {} toEntity({}DTO dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity(@MappingTarget {} entity, {}DTO dto);
}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_base_package() end), i(1, "Entity"),
        f(function() return get_base_package() end), rep(1),
        rep(1),
        rep(1), rep(1),
        rep(1), rep(1),
        rep(1), rep(1),
    })),

    -- Dynamic Exception
    s("spring_exception_ctx", fmt([[
package {}.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.{})
public class {} extends RuntimeException {{

    public {}(String message) {{
        super(message);
    }}

    public {}(String message, Throwable cause) {{
        super(message, cause);
    }}
}}
]], {
        f(function() return get_base_package() end),
        c(1, {
            t("NOT_FOUND"),
            t("BAD_REQUEST"),
            t("CONFLICT"),
            t("FORBIDDEN"),
            t("UNAUTHORIZED"),
        }),
        f(function() return get_class_name() end),
        f(function() return get_class_name() end),
        f(function() return get_class_name() end),
    })),

    -- Dynamic Config class
    s("spring_config_ctx", fmt([[
package {}.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class {} {{
    {}
}}
]], {
        f(function() return get_base_package() end),
        f(function() return get_class_name() end),
        i(0),
    })),

    -- Dynamic Test
    s("spring_test_ctx", fmt([[
package {};

import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest
class {}Test {{

    @Test
    @DisplayName("{}")
    void {}() {{
        {}
    }}
}}
]], {
        f(function() return get_package() end),
        f(function() return get_class_name():gsub("Test$", "") end),
        i(1, "should do something"),
        i(2, "shouldDoSomething"),
        i(0),
    })),

    -- Simple package declaration based on path
    s("pkg", fmt([[
package {};
]], {
        f(function() return get_package() end),
    })),
})

return {}
