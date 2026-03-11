-- Controller snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- REST Controller with CRUD
    -- In UserController.java -> uses User as entity, imports UserDto, UserService
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

    private final {entity}Service {entity_var}Service;

    @GetMapping
    public ResponseEntity<List<{entity}Dto>> getAll() {{
        return ResponseEntity.ok({entity_var}Service.findAll());
    }}

    @GetMapping("/{{id}}")
    public ResponseEntity<{entity}Dto> getById(@PathVariable Long id) {{
        return ResponseEntity.ok({entity_var}Service.findById(id));
    }}

    @PostMapping
    public ResponseEntity<{entity}Dto> create(@Valid @RequestBody {entity}Dto dto) {{
        return ResponseEntity.status(HttpStatus.CREATED).body({entity_var}Service.create(dto));
    }}

    @PutMapping("/{{id}}")
    public ResponseEntity<{entity}Dto> update(@PathVariable Long id, @Valid @RequestBody {entity}Dto dto) {{
        return ResponseEntity.ok({entity_var}Service.update(id, dto));
    }}

    @DeleteMapping("/{{id}}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {{
        {entity_var}Service.delete(id);
        return ResponseEntity.noContent().build();
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        entity = f(function() return h.entity_name() end),
        entity_var = f(function() return h.entity_var() end),
        endpoint = f(function() return h.endpoint() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Simple Controller (no service dependency)
    s("spring_controller_simple_ctx", fmt([[
package {pkg}.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/{endpoint}")
@RequiredArgsConstructor
public class {class_name} {{

    @GetMapping
    public ResponseEntity<String> get() {{
        return ResponseEntity.ok("Hello from {entity}");
    }}

    @GetMapping("/{{id}}")
    public ResponseEntity<String> getById(@PathVariable Long id) {{
        return ResponseEntity.ok("{entity} " + id);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        endpoint = f(function() return h.endpoint() end),
        class_name = f(function() return h.class_name() end),
        entity = f(function() return h.entity_name() end),
    })),
}
