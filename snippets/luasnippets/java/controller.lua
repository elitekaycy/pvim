-- Controller snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- REST Controller with CRUD
    s("spring_controller_ctx", fmt([[
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
public class {class_name} {{

    private final {entity}Service service;

    @GetMapping
    public ResponseEntity<List<{entity}Dto>> getAll() {{
        return ResponseEntity.ok(service.findAll());
    }}

    @GetMapping("/{{id}}")
    public ResponseEntity<{entity}Dto> getById(@PathVariable Long id) {{
        return ResponseEntity.ok(service.findById(id));
    }}

    @PostMapping
    public ResponseEntity<{entity}Dto> create(@Valid @RequestBody {entity}Dto dto) {{
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(dto));
    }}

    @PutMapping("/{{id}}")
    public ResponseEntity<{entity}Dto> update(@PathVariable Long id, @Valid @RequestBody {entity}Dto dto) {{
        return ResponseEntity.ok(service.update(id, dto));
    }}

    @DeleteMapping("/{{id}}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {{
        service.delete(id);
        return ResponseEntity.noContent().build();
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        endpoint = i(2, "entities"),
        class_name = f(function() return h.class_name() end),
    }, { repeat_duplicates = true })),

    -- Controller with Pagination
    s("spring_controller_page_ctx", fmt([[
package {pkg}.controller;

import {pkg}.dto.{entity}Dto;
import {pkg}.service.{entity}Service;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/{endpoint}")
@RequiredArgsConstructor
public class {class_name} {{

    private final {entity}Service service;

    @GetMapping
    public ResponseEntity<Page<{entity}Dto>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {{
        Sort sort = sortDir.equalsIgnoreCase("asc")
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        return ResponseEntity.ok(service.findAll(pageable));
    }}

    @GetMapping("/{{id}}")
    public ResponseEntity<{entity}Dto> getById(@PathVariable Long id) {{
        return ResponseEntity.ok(service.findById(id));
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        endpoint = i(2, "entities"),
        class_name = f(function() return h.class_name() end),
    }, { repeat_duplicates = true })),
}
