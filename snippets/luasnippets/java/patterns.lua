-- Design pattern snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f, rep = h.s, h.fmt, h.i, h.f, h.rep

return {
    -- Singleton Pattern (Double-checked locking)
    s("pattern_singleton_ctx", fmt([[
package {pkg};

public class {class_name} {{

    private static volatile {class_name} instance;

    private {class_name}() {{
        // Private constructor to prevent instantiation
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

    public void {method}() {{
        {cursor}
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
        method = i(1, "doSomething"),
        cursor = i(0),
    })),

    -- Singleton Enum (Recommended)
    s("pattern_singleton_enum_ctx", fmt([[
package {pkg};

public enum {class_name} {{

    INSTANCE;

    private {type} {field};

    public {type} get{Field}() {{
        return {field};
    }}

    public void set{Field}({type} {field}) {{
        this.{field} = {field};
    }}

    public void {method}() {{
        {cursor}
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
        type = i(1, "String"),
        field = i(2, "value"),
        Field = f(function(args) return h.uppercase_first(args[1][1]) end, {2}),
        method = i(3, "doSomething"),
        cursor = i(0),
    })),

    -- Factory Pattern
    s("pattern_factory_ctx", fmt([[
package {pkg}.factory;

public class {class_name} {{

    public static {product} create({param_type} type) {{
        return switch (type.toLowerCase()) {{
            case "{type_a}" -> new {impl_a}();
            case "{type_b}" -> new {impl_b}();
            default -> throw new IllegalArgumentException("Unknown type: " + type);
        }};
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        product = i(1, "Product"),
        param_type = i(2, "String"),
        type_a = i(3, "a"),
        impl_a = i(4, "ConcreteProductA"),
        type_b = i(5, "b"),
        impl_b = i(6, "ConcreteProductB"),
    })),

    -- Builder Pattern
    s("pattern_builder_ctx", fmt([[
package {pkg};

public class {class_name} {{

    private final {type1} {field1};
    private final {type2} {field2};
    private final {type3} {field3};

    private {class_name}(Builder builder) {{
        this.{field1} = builder.{field1};
        this.{field2} = builder.{field2};
        this.{field3} = builder.{field3};
    }}

    public {type1} get{Field1}() {{ return {field1}; }}
    public {type2} get{Field2}() {{ return {field2}; }}
    public {type3} get{Field3}() {{ return {field3}; }}

    public static Builder builder() {{
        return new Builder();
    }}

    public static class Builder {{
        private {type1} {field1};
        private {type2} {field2};
        private {type3} {field3};

        public Builder {field1}({type1} {field1}) {{
            this.{field1} = {field1};
            return this;
        }}

        public Builder {field2}({type2} {field2}) {{
            this.{field2} = {field2};
            return this;
        }}

        public Builder {field3}({type3} {field3}) {{
            this.{field3} = {field3};
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
        type1 = i(1, "String"),
        field1 = i(2, "name"),
        Field1 = f(function(args) return h.uppercase_first(args[1][1]) end, {2}),
        type2 = i(3, "String"),
        field2 = i(4, "description"),
        Field2 = f(function(args) return h.uppercase_first(args[1][1]) end, {4}),
        type3 = i(5, "int"),
        field3 = i(6, "value"),
        Field3 = f(function(args) return h.uppercase_first(args[1][1]) end, {6}),
    }, { repeat_duplicates = true })),

    -- Strategy Pattern
    s("pattern_strategy_ctx", fmt([[
package {pkg}.strategy;

// Strategy Interface
public interface {class_name} {{
    {return_type} execute({param_type} input);
}}

// Concrete Strategy A
class {strategy_a} implements {class_name} {{
    @Override
    public {return_type} execute({param_type} input) {{
        // Implementation A
        {cursor}
    }}
}}

// Concrete Strategy B
class {strategy_b} implements {class_name} {{
    @Override
    public {return_type} execute({param_type} input) {{
        // Implementation B
    }}
}}

// Context
class {class_name}Context {{
    private {class_name} strategy;

    public void setStrategy({class_name} strategy) {{
        this.strategy = strategy;
    }}

    public {return_type} executeStrategy({param_type} input) {{
        return strategy.execute(input);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        return_type = i(1, "void"),
        param_type = i(2, "Object"),
        strategy_a = i(3, "ConcreteStrategyA"),
        strategy_b = i(4, "ConcreteStrategyB"),
        cursor = i(0),
    })),

    -- Observer Pattern
    s("pattern_observer_ctx", fmt([[
package {pkg}.observer;

import java.util.ArrayList;
import java.util.List;

// Observer Interface
public interface {class_name} {{
    void update({state_type} message);
}}

// Subject
class Subject {{
    private final List<{class_name}> observers = new ArrayList<>();
    private {state_type} state;

    public void attach({class_name} observer) {{
        observers.add(observer);
    }}

    public void detach({class_name} observer) {{
        observers.remove(observer);
    }}

    public void setState({state_type} state) {{
        this.state = state;
        notifyObservers();
    }}

    private void notifyObservers() {{
        observers.forEach(o -> o.update(state));
    }}
}}

// Concrete Observer
class Concrete{class_name} implements {class_name} {{
    private final String name;

    public Concrete{class_name}(String name) {{
        this.name = name;
    }}

    @Override
    public void update({state_type} message) {{
        System.out.println(name + " received: " + message);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        state_type = i(1, "String"),
    })),

    -- Facade Pattern (Spring)
    s("pattern_facade_ctx", fmt([[
package {pkg}.facade;

import {pkg}.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class {class_name} {{

    private final {service_a} {service_a_var};
    private final {service_b} {service_b_var};
    private final {service_c} {service_c_var};

    /**
     * Simplified interface to complex subsystem
     */
    public {result} performComplexOperation({request} request) {{
        // Coordinate multiple services
        var resultA = {service_a_var}.process(request);
        var resultB = {service_b_var}.transform(resultA);
        return {service_c_var}.finalize(resultB);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        service_a = i(1, "ServiceA"),
        service_a_var = f(function(args) return h.lowercase_first(args[1][1]) end, {1}),
        service_b = i(2, "ServiceB"),
        service_b_var = f(function(args) return h.lowercase_first(args[1][1]) end, {2}),
        service_c = i(3, "ServiceC"),
        service_c_var = f(function(args) return h.lowercase_first(args[1][1]) end, {3}),
        result = i(4, "Result"),
        request = i(5, "Request"),
    })),

    -- Template Method Pattern
    s("pattern_template_ctx", fmt([[
package {pkg}.template;

public abstract class {class_name} {{

    // Template method (final to prevent override)
    public final {return_type} execute() {{
        step1();
        step2();
        hook();
        step3();
    }}

    // Required steps (abstract)
    protected abstract void step1();
    protected abstract void step2();
    protected abstract void step3();

    // Optional hook (can be overridden)
    protected void hook() {{
        // Default implementation (empty)
    }}
}}

// Concrete Implementation
class Concrete{class_name} extends {class_name} {{

    @Override
    protected void step1() {{
        System.out.println("Step 1");
    }}

    @Override
    protected void step2() {{
        System.out.println("Step 2");
    }}

    @Override
    protected void step3() {{
        System.out.println("Step 3");
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        return_type = i(1, "void"),
    })),
}
