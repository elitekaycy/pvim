-- DTO snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- DTO with Lombok
    s("spring_dto_ctx", fmt([[
package {pkg}.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {class_name} {{

    private Long id;
    {cursor}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        cursor = i(0),
    })),

    -- Record DTO
    s("spring_record_ctx", fmt([[
package {pkg}.dto;

public record {class_name}(
    Long id{cursor}
) {{}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        cursor = i(0),
    })),

    -- Request DTO
    s("spring_request_ctx", fmt([[
package {pkg}.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {class_name} {{

    @NotBlank(message = "{field} is required")
    private String {field_var};
    {cursor}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        field = i(1, "name"),
        field_var = f(function(args) return h.lowercase_first(args[1][1]) end, {1}),
        cursor = i(0),
    })),

    -- Response DTO
    s("spring_response_ctx", fmt([[
package {pkg}.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {class_name} {{

    private Long id;
    {cursor}
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        cursor = i(0),
    })),
}
