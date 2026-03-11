-- Test snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- Unit Test with Mockito
    -- In UserServiceTest.java -> tests UserService, mocks UserRepository
    s("spring_test_ctx", fmt([[
package {pkg};

import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class {class_name} {{

    @Mock
    private {entity}Repository {entity_var}Repository;

    @InjectMocks
    private {entity}Service underTest;

    @BeforeEach
    void setUp() {{
        // Setup
    }}

    @Test
    @DisplayName("should find all")
    void shouldFindAll() {{
        // Given

        // When

        // Then
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
        entity = f(function() return h.entity_name() end),
        entity_var = f(function() return h.entity_var() end),
    })),

    -- Simple Test (no mocks)
    s("spring_test_simple_ctx", fmt([[
package {pkg};

import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.*;

class {class_name} {{

    @Test
    @DisplayName("should work")
    void shouldWork() {{
        // Given

        // When

        // Then
        assertThat(true).isTrue();
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
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
    @DisplayName("should return 200")
    void shouldReturn200() throws Exception {{
        mockMvc.perform(get("/api/{endpoint}")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        class_name = f(function() return h.class_name() end),
        endpoint = f(function() return h.endpoint() end),
    })),

    -- Repository Test (DataJpaTest)
    s("spring_repository_test_ctx", fmt([[
package {pkg};

import {base_pkg}.entity.{entity};
import {base_pkg}.repository.{entity}Repository;
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
    @DisplayName("should find by id")
    void shouldFindById() {{
        // Given
        {entity} entity = {entity}.builder().build();
        entityManager.persistAndFlush(entity);

        // When
        var result = repository.findById(entity.getId());

        // Then
        assertThat(result).isPresent();
    }}
}}
]], {
        pkg = f(function() return h.pkg() end),
        base_pkg = f(function() return h.base_pkg() end),
        entity = f(function() return h.entity_name() end),
        class_name = f(function() return h.class_name() end),
    })),
}
