-- Test snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- Unit Test with Mockito
    s("spring_test_ctx", fmt([[
package {pkg};

import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class {class_name}Test {{

    @Mock
    private {dep} {dep_var};

    @InjectMocks
    private {class_name} underTest;

    @BeforeEach
    void setUp() {{
        // Setup
    }}

    @Test
    @DisplayName("{desc}")
    void {method}() {{
        // Given

        // When

        // Then
        {cursor}
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name():gsub("Test$", "") end),
        dep = i(1, "Repository"),
        dep_var = f(function(args) return h.lowercase_first(args[1][1]) end, {1}),
        desc = i(2, "should do something"),
        method = i(3, "shouldDoSomething"),
        cursor = i(0),
    })),

    -- Integration Test with MockMvc
    s("spring_integration_test_ctx", fmt([[
package {pkg};

import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class {class_name} {{

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("{desc}")
    void {method}() throws Exception {{
        mockMvc.perform(get("{endpoint}")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
        desc = i(1, "should return 200"),
        method = i(2, "shouldReturn200"),
        endpoint = i(3, "/api/entities"),
    })),

    -- Repository Test (DataJpaTest)
    s("spring_repository_test_ctx", fmt([[
package {pkg};

import {base_pkg}.entity.{entity};
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import static org.assertj.core.api.Assertions.*;

@DataJpaTest
class {class_name} {{

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private {entity}Repository repository;

    @Test
    @DisplayName("{desc}")
    void {method}() {{
        // Given
        {entity} entity = {entity}.builder()
                .build();
        entityManager.persistAndFlush(entity);

        // When
        var result = repository.findById(entity.getId());

        // Then
        assertThat(result).isPresent();
        {cursor}
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        base_pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
        desc = i(2, "should find entity by id"),
        method = i(3, "shouldFindEntityById"),
        cursor = i(0),
    }, { repeat_duplicates = true })),

    -- WebMvc Test (Controller slice)
    s("spring_webmvc_test_ctx", fmt([[
package {pkg};

import {base_pkg}.controller.{entity}Controller;
import {base_pkg}.service.{entity}Service;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest({entity}Controller.class)
class {class_name} {{

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private {entity}Service service;

    @Test
    @DisplayName("{desc}")
    void {method}() throws Exception {{
        // Given
        when(service.findAll()).thenReturn(java.util.List.of());

        // When & Then
        mockMvc.perform(get("/api/{endpoint}")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().json("[]"));
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        base_pkg = f(function() return h.base_pkg() end),
        entity = i(1, "Entity"),
        class_name = f(function() return h.class_name() end),
        desc = i(2, "should return empty list"),
        method = i(3, "shouldReturnEmptyList"),
        endpoint = i(4, "entities"),
    }, { repeat_duplicates = true })),
}
