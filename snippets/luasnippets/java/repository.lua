-- Repository and Mapper snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- JPA Repository
    s("spring_repository_ctx", fmt([[
package {pkg}.repository;

import {pkg}.entity.{entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface {class_name} extends JpaRepository<{entity}, Long> {{

    Optional<{entity}> findBy{field}(String {field_lower});

    List<{entity}> findBy{field}ContainingIgnoreCase(String {field_lower});

    boolean existsBy{field}(String {field_lower});
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
        field = i(2, "Name"),
        field_lower = f(function(args) return h.lowercase_first(args[1][1]) end, {2}),
    }, { repeat_duplicates = true })),

    -- MapStruct Mapper
    s("spring_mapper_ctx", fmt([[
package {pkg}.mapper;

import {pkg}.dto.{entity}Dto;
import {pkg}.entity.{entity};
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface {class_name} {{

    {entity}Dto toDto({entity} entity);

    {entity} toEntity({entity}Dto dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity({entity}Dto dto, @MappingTarget {entity} entity);
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
    }, { repeat_duplicates = true })),

    -- Manual Mapper
    s("spring_mapper_manual_ctx", fmt([[
package {pkg}.mapper;

import {pkg}.dto.{entity}Dto;
import {pkg}.entity.{entity};
import org.springframework.stereotype.Component;

@Component
public class {class_name} {{

    public {entity}Dto toDto({entity} entity) {{
        if (entity == null) return null;
        return {entity}Dto.builder()
                .id(entity.getId())
                // TODO: map other fields
                .build();
    }}

    public {entity} toEntity({entity}Dto dto) {{
        if (dto == null) return null;
        return {entity}.builder()
                // TODO: map fields
                .build();
    }}

    public void updateEntity({entity}Dto dto, {entity} entity) {{
        if (dto == null || entity == null) return;
        // TODO: update fields
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
    }, { repeat_duplicates = true })),
}
