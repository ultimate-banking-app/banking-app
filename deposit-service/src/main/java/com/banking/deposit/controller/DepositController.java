package com.banking.deposit.controller;

import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/deposits")
public class DepositController {

    @PostMapping("/cash")
    public Map<String, Object> cashDeposit(@RequestParam String accountId,
                                         @RequestParam BigDecimal amount,
                                         @RequestParam String location) {
        Map<String, Object> response = new HashMap<>();
        response.put("depositId", "DEP" + System.currentTimeMillis());
        response.put("status", "COMPLETED");
        response.put("type", "CASH");
        response.put("amount", amount);
        response.put("accountId", accountId);
        response.put("location", location);
        return response;
    }

    @PostMapping("/check")
    public Map<String, Object> checkDeposit(@RequestParam String accountId,
                                          @RequestParam BigDecimal amount,
                                          @RequestParam String checkNumber) {
        Map<String, Object> response = new HashMap<>();
        response.put("depositId", "CHK" + System.currentTimeMillis());
        response.put("status", "PENDING");
        response.put("type", "CHECK");
        response.put("amount", amount);
        response.put("accountId", accountId);
        response.put("holdDays", "2-3");
        return response;
    }
}
