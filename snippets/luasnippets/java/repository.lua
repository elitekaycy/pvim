-- Repository and Mapper snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- JPA Repository
    -- In UserRepository.java -> uses User as entity
    s("spring_repository_ctx", fmt([[
package {pkg}.repository;

import {pkg}.entity.{entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface {class_name} extends JpaRepository<{entity}, Long> {{

    Optional<{entity}> findByName(String name);

    boolean existsByName(String name);
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = f(function() return h.entity_name() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Simple Repository (just extends JpaRepository)
    s("spring_repository_simple_ctx", fmt([[
package {pkg}.repository;

import {pkg}.entity.{entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface {class_name} extends JpaRepository<{entity}, Long> {{
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = f(function() return h.entity_name() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- MapStruct Mapper
    -- In UserMapper.java -> uses User as entity
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
        entity = f(function() return h.entity_name() end),
        class_name = f(function() return h.class_name() end),
    })),
}
