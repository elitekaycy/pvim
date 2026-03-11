-- Design pattern snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, f = h.s, h.fmt, h.f

return {
    -- Singleton Pattern (Double-checked locking)
    s("pattern_singleton_ctx", fmt([[
package {pkg};

public class {class_name} {{

    private static volatile {class_name} instance;

    private {class_name}() {{
    }}

    public static {class_name} getInstance() {{
        if (instance == null) {{
            synchronized ({class_name}.class) {{
                if (instance == null) {{
                    instance = new {class_name}();
                }}
            }}
        }}
        return instance;
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Singleton Enum (Recommended)
    s("pattern_singleton_enum_ctx", fmt([[
package {pkg};

public enum {class_name} {{

    INSTANCE;

    public void execute() {{
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Builder Pattern
    s("pattern_builder_ctx", fmt([[
package {pkg};

public class {class_name} {{

    private final String name;
    private final String value;

    private {class_name}(Builder builder) {{
        this.name = builder.name;
        this.value = builder.value;
    }}

    public String getName() {{ return name; }}
    public String getValue() {{ return value; }}

    public static Builder builder() {{
        return new Builder();
    }}

    public static class Builder {{
        private String name;
        private String value;

        public Builder name(String name) {{
            this.name = name;
            return this;
        }}

        public Builder value(String value) {{
            this.value = value;
            return this;
        }}

        public {class_name} build() {{
            return new {class_name}(this);
        }}
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Factory Pattern
    s("pattern_factory_ctx", fmt([[
package {pkg};

public class {class_name} {{

    public static Object create(String type) {{
        return switch (type.toLowerCase()) {{
            case "a" -> new Object();
            case "b" -> new Object();
            default -> throw new IllegalArgumentException("Unknown type: " + type);
        }};
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Strategy Pattern Interface
    s("pattern_strategy_ctx", fmt([[
package {pkg};

public interface {class_name} {{

    void execute();
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Template Method Pattern
    s("pattern_template_ctx", fmt([[
package {pkg};

public abstract class {class_name} {{

    public final void execute() {{
        step1();
        step2();
        hook();
        step3();
    }}

    protected abstract void step1();
    protected abstract void step2();
    protected abstract void step3();

    protected void hook() {{
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
    })),
}
