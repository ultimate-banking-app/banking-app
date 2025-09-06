package com.banking.audit.repository;

import com.banking.audit.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, String> {
    Page<AuditLog> findByUserId(String userId, Pageable pageable);
    Page<AuditLog> findByAction(String action, Pageable pageable);
    Page<AuditLog> findByUserIdAndAction(String userId, String action, Pageable pageable);
}
