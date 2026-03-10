-- Common/utility snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

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

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class {class_name} {{

    @Scheduled(cron = "{cron}")
    public void {method}() {{
        log.info("Running scheduled task: {class_name}");
        {cursor}
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        cron = i(1, "0 0 * * * *"),
        method = i(2, "execute"),
        cursor = i(0),
    })),

    -- Event Listener
    s("spring_event_listener_ctx", fmt([[
package {pkg}.event;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class {class_name} {{

    @Async
    @EventListener
    public void handle({event} event) {{
        log.info("Handling event: {{}}", event);
        {cursor}
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        event = i(1, "CustomEvent"),
        cursor = i(0),
    })),

    -- Custom Event
    s("spring_event_ctx", fmt([[
package {pkg}.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

@Getter
public class {class_name} extends ApplicationEvent {{

    private final {data_type} {data_field};

    public {class_name}(Object source, {data_type} {data_field}) {{
        super(source);
        this.{data_field} = {data_field};
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        data_type = i(1, "String"),
        data_field = i(2, "data"),
    })),

    -- Feign Client
    s("spring_feign_ctx", fmt([[
package {pkg}.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "{name}", url = "{url}")
public interface {class_name} {{

    @GetMapping("{endpoint}")
    {response} get{method}();

    @PostMapping("{endpoint}")
    {response} create{method}(@RequestBody {request} request);
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
        name = i(1, "external-service"),
        url = i(2, "${external.service.url}"),
        endpoint = i(3, "/api/resource"),
        response = i(4, "ResponseDto"),
        method = i(5, "Resource"),
        request = i(6, "RequestDto"),
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

    @Pointcut("{pointcut}")
    public void targetMethods() {{}}

    @Around("targetMethods()")
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
        pointcut = i(1, "execution(* com.example.service.*.*(..))"),
    })),
}
