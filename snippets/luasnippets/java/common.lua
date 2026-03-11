-- Common/utility snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, f = h.s, h.fmt, h.f

return {
    -- Package declaration
    s("pkg", fmt([[
package {pkg};
]], {
        pkg = f(function() return h.pkg() end),
    })),

    -- Main Application class
    s("spring_main_ctx", fmt([[
package {pkg};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class {class_name} {{

    public static void main(String[] args) {{
        SpringApplication.run({class_name}.class, args);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Scheduled Task
    s("spring_scheduled_ctx", fmt([[
package {pkg}.scheduler;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class {class_name} {{

    @Scheduled(cron = "0 0 * * * *")
    public void execute() {{
        log.info("Running scheduled task");
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Event Listener
    s("spring_event_listener_ctx", fmt([[
package {pkg}.event;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class {class_name} {{

    @Async
    @EventListener
    public void handle(Object event) {{
        log.info("Handling event: {{}}", event);
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Custom Event
    s("spring_event_ctx", fmt([[
package {pkg}.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

@Getter
public class {class_name} extends ApplicationEvent {{

    private final String data;

    public {class_name}(Object source, String data) {{
        super(source);
        this.data = data;
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Aspect
    s("spring_aspect_ctx", fmt([[
package {pkg}.aspect;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Slf4j
@Aspect
@Component
public class {class_name} {{

    @Around("execution(* {pkg}.service.*.*(..))")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {{
        String methodName = joinPoint.getSignature().getName();
        log.debug("Before: {{}}", methodName);

        long start = System.currentTimeMillis();
        Object result = joinPoint.proceed();
        long duration = System.currentTimeMillis() - start;

        log.debug("After: {{}} ({{}}ms)", methodName, duration);
        return result;
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),
}
