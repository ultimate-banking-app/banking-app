package com.banking.balance.controller;

import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/balance")
public class BalanceController {

    @GetMapping("/{accountId}")
    public Map<String, Object> getBalance(@PathVariable String accountId) {
        Map<String, Object> response = new HashMap<>();
        response.put("accountId", accountId);
        response.put("balance", new BigDecimal("1000.00"));
        response.put("currency", "USD");
        response.put("availableBalance", new BigDecimal("950.00"));
        return response;
    }

    @GetMapping("/{accountId}/statement")
    public Map<String, Object> getStatement(@PathVariable String accountId,
                                          @RequestParam(defaultValue = "30") int days) {
        Map<String, Object> response = new HashMap<>();
        response.put("accountId", accountId);
        response.put("period", days + " days");
        response.put("transactions", new Object[]{});
        return response;
    }
}
