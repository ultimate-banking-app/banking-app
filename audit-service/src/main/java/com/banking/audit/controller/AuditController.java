package com.banking.audit.controller;

import com.banking.audit.entity.AuditLog;
import com.banking.audit.service.AuditService;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/audit")
@CrossOrigin(origins = "*")
public class AuditController {

    @Autowired
    private AuditService auditService;
    
    private final Counter auditRequestsCounter;

    public AuditController(MeterRegistry meterRegistry) {
        this.auditRequestsCounter = Counter.builder("banking_audit_requests_total")
            .description("Total audit requests")
            .tag("service", "audit")
            .register(meterRegistry);
    }

    @PostMapping("/log")
    public ResponseEntity<AuditLog> createAuditLog(@RequestBody AuditLog auditLog) {
        auditRequestsCounter.increment();
        AuditLog saved = auditService.createAuditLog(auditLog);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/logs")
    public ResponseEntity<Page<AuditLog>> getAuditLogs(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String action,
            Pageable pageable) {
        auditRequestsCounter.increment();
        Page<AuditLog> logs = auditService.getAuditLogs(userId, action, pageable);
        return ResponseEntity.ok(logs);
    }

    @GetMapping("/logs/{id}")
    public ResponseEntity<AuditLog> getAuditLog(@PathVariable String id) {
        auditRequestsCounter.increment();
        AuditLog log = auditService.getAuditLog(id);
        return ResponseEntity.ok(log);
    }
}
