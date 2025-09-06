package com.banking.audit.controller;

import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/audit")
public class AuditController {

    @GetMapping("/transactions/{accountId}")
    public Map<String, Object> getTransactionHistory(@PathVariable String accountId,
                                                   @RequestParam(defaultValue = "30") int days) {
        Map<String, Object> response = new HashMap<>();
        response.put("accountId", accountId);
        response.put("period", days + " days");
        response.put("totalTransactions", 0);
        response.put("transactions", new Object[]{});
        return response;
    }

    @PostMapping("/log")
    public Map<String, Object> logTransaction(@RequestParam String transactionId,
                                            @RequestParam String type,
                                            @RequestParam String details) {
        Map<String, Object> response = new HashMap<>();
        response.put("auditId", "AUDIT" + System.currentTimeMillis());
        response.put("status", "LOGGED");
        response.put("transactionId", transactionId);
        response.put("type", type);
        return response;
    }

    @GetMapping("/compliance/{accountId}")
    public Map<String, Object> getComplianceReport(@PathVariable String accountId) {
        Map<String, Object> response = new HashMap<>();
        response.put("accountId", accountId);
        response.put("complianceStatus", "COMPLIANT");
        response.put("lastReviewDate", "2024-01-01");
        response.put("nextReviewDate", "2024-07-01");
        return response;
    }
}
