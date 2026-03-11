-- Service snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- Service Interface (contract)
    -- In UserService.java -> creates interface for User entity
    s("spring_service_ctx", fmt([[
package {pkg}.service;

import {pkg}.dto.{entity}Dto;

import java.util.List;

public interface {class_name} {{

    List<{entity}Dto> findAll();

    {entity}Dto findById(Long id);

    {entity}Dto create({entity}Dto dto);

    {entity}Dto update(Long id, {entity}Dto dto);

    void delete(Long id);
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = f(function() return h.entity_name() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Service Implementation with CRUD
    -- In UserServiceImpl.java -> implements UserService interface
    s("spring_service_impl_ctx", fmt([[
package {pkg}.service.impl;

import {pkg}.dto.{entity}Dto;
import {pkg}.entity.{entity};
import {pkg}.mapper.{entity}Mapper;
import {pkg}.repository.{entity}Repository;
import {pkg}.service.{entity}Service;
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
public class {class_name} implements {entity}Service {{

    private final {entity}Repository {entity_var}Repository;
    private final {entity}Mapper {entity_var}Mapper;

    @Override
    @Transactional(readOnly = true)
    public List<{entity}Dto> findAll() {{
        log.debug("Finding all {entity}s");
        return {entity_var}Repository.findAll().stream()
                .map({entity_var}Mapper::toDto)
                .toList();
    }}

    @Override
    @Transactional(readOnly = true)
    public {entity}Dto findById(Long id) {{
        log.debug("Finding {entity} by id: {{}}", id);
        return {entity_var}Repository.findById(id)
                .map({entity_var}Mapper::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("{entity} not found: " + id));
    }}

    @Override
    public {entity}Dto create({entity}Dto dto) {{
        log.info("Creating {entity}");
        {entity} entity = {entity_var}Mapper.toEntity(dto);
        return {entity_var}Mapper.toDto({entity_var}Repository.save(entity));
    }}

    @Override
    public {entity}Dto update(Long id, {entity}Dto dto) {{
        log.info("Updating {entity}: {{}}", id);
        {entity} entity = {entity_var}Repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("{entity} not found: " + id));
        {entity_var}Mapper.updateEntity(dto, entity);
        return {entity_var}Mapper.toDto({entity_var}Repository.save(entity));
    }}

    @Override
    public void delete(Long id) {{
        log.info("Deleting {entity}: {{}}", id);
        if (!{entity_var}Repository.existsById(id)) {{
            throw new ResourceNotFoundException("{entity} not found: " + id);
        }}
        {entity_var}Repository.deleteById(id);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = f(function() return h.entity_name() end),
        entity_var = f(function() return h.entity_var() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Simple Service (standalone, no interface)
    s("spring_service_simple_ctx", fmt([[
package {pkg}.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class {class_name} {{

    public void process() {{
        log.info("Processing in {class_name}");
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),
}
