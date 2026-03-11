-- Entity snippets with context awareness
local h = require("snippets.java.helpers")
local s, fmt, i, f = h.s, h.fmt, h.i, h.f

return {
    -- Entity with Lombok
    -- In User.java -> creates User entity with users table
    s("spring_entity_ctx", fmt([[
package {pkg}.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "{table}")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class {class_name} implements Serializable {{

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {{
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }}

    @PreUpdate
    protected void onUpdate() {{
        this.updatedAt = LocalDateTime.now();
    }}
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        table = f(function() return h.table_name() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Simple Entity (minimal)
    s("spring_entity_simple_ctx", fmt([[
package {pkg}.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "{table}")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class {class_name} {{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        table = f(function() return h.table_name() end),
        class_name = f(function() return h.class_name() end),
    })),

    -- Auditable Base Entity
    s("spring_entity_audit_ctx", fmt([[
package {pkg}.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.io.Serializable;
import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class {class_name} implements Serializable {{

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @CreatedBy
    @Column(name = "created_by", updatable = false)
    private String createdBy;

    @LastModifiedBy
    @Column(name = "updated_by")
    private String updatedBy;
}}
]], {
        pkg = f(function() return h.base_pkg() end),
        class_name = f(function() return h.class_name() end),
    })),
}
