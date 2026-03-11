-- Config snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, f = h.s, h.fmt, h.f

return {
    -- Simple Config class
    s("spring_config_ctx", fmt([[
package {pkg}.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class {class_name} {{

}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Security Config
    s("spring_config_security_ctx", fmt([[
package {pkg}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class {class_name} {{

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {{
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**", "/actuator/health").permitAll()
                        .anyRequest().authenticated()
                )
                .build();
    }}

    @Bean
    public PasswordEncoder passwordEncoder() {{
        return new BCryptPasswordEncoder();
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- CORS Config
    s("spring_config_cors_ctx", fmt([[
package {pkg}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
public class {class_name} {{

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {{
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("http://localhost:3000"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Auditing Config
    s("spring_config_audit_ctx", fmt([[
package {pkg}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.Optional;

@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class {class_name} {{

    @Bean
    public AuditorAware<String> auditorProvider() {{
        return () -> Optional.of("system");
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),
}
