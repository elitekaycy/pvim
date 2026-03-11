-- DTO snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- DTO with Lombok
    -- In UserDto.java -> creates UserDto class
    s("spring_dto_ctx", fmt([[
package {pkg}.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {class_name} {{

    private Long id;
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Record DTO
    s("spring_record_ctx", fmt([[
package {pkg}.dto;

public record {class_name}(
    Long id
) {{}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Request DTO with validation
    s("spring_request_ctx", fmt([[
package {pkg}.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {class_name} {{

    @NotBlank(message = "Name is required")
    private String name;
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Response DTO with timestamps
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
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),
}
