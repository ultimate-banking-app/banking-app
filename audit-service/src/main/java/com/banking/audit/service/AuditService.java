package com.banking.audit.service;

import com.banking.audit.entity.AuditLog;
import com.banking.audit.repository.AuditLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuditService {

    @Autowired
    private AuditLogRepository auditLogRepository;

    public AuditLog createAuditLog(AuditLog auditLog) {
        if (auditLog.getId() == null) {
            auditLog.setId(UUID.randomUUID().toString());
        }
        return auditLogRepository.save(auditLog);
    }

    public Page<AuditLog> getAuditLogs(String userId, String action, Pageable pageable) {
        if (userId != null && action != null) {
            return auditLogRepository.findByUserIdAndAction(userId, action, pageable);
        } else if (userId != null) {
            return auditLogRepository.findByUserId(userId, pageable);
        } else if (action != null) {
            return auditLogRepository.findByAction(action, pageable);
        } else {
            return auditLogRepository.findAll(pageable);
        }
    }

    public AuditLog getAuditLog(String id) {
        return auditLogRepository.findById(id).orElse(null);
    }
}
