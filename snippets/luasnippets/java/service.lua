-- Service snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- Service with CRUD
    s("spring_service_ctx", fmt([[
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
public class {class_name} {{

    private final {entity}Repository repository;
    private final {entity}Mapper mapper;

    @Transactional(readOnly = true)
    public List<{entity}Dto> findAll() {{
        log.debug("Finding all {entity}s");
        return repository.findAll().stream().map(mapper::toDto).toList();
    }}

    @Transactional(readOnly = true)
    public {entity}Dto findById(Long id) {{
        log.debug("Finding {entity} by id: {{}}", id);
        return repository.findById(id)
                .map(mapper::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("{entity} not found: " + id));
    }}

    public {entity}Dto create({entity}Dto dto) {{
        log.info("Creating {entity}");
        {entity} entity = mapper.toEntity(dto);
        return mapper.toDto(repository.save(entity));
    }}

    public {entity}Dto update(Long id, {entity}Dto dto) {{
        log.info("Updating {entity}: {{}}", id);
        {entity} entity = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("{entity} not found: " + id));
        mapper.updateEntity(dto, entity);
        return mapper.toDto(repository.save(entity));
    }}

    public void delete(Long id) {{
        log.info("Deleting {entity}: {{}}", id);
        if (!repository.existsById(id)) {{
            throw new ResourceNotFoundException("{entity} not found: " + id);
        }}
        repository.deleteById(id);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
    }, { repeat_duplicates = true })),

    -- Service Interface
    s("spring_service_interface_ctx", fmt([[
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
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
    }, { repeat_duplicates = true })),
}
