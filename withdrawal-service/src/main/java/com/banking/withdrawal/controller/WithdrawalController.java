package com.banking.withdrawal.controller;

import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/withdrawals")
public class WithdrawalController {

    @PostMapping("/atm")
    public Map<String, Object> atmWithdrawal(@RequestParam String accountId,
                                           @RequestParam BigDecimal amount,
                                           @RequestParam String atmId) {
        Map<String, Object> response = new HashMap<>();
        response.put("withdrawalId", "ATM" + System.currentTimeMillis());
        response.put("status", "COMPLETED");
        response.put("type", "ATM");
        response.put("amount", amount);
        response.put("accountId", accountId);
        response.put("atmId", atmId);
        return response;
    }

    @PostMapping("/branch")
    public Map<String, Object> branchWithdrawal(@RequestParam String accountId,
                                              @RequestParam BigDecimal amount,
                                              @RequestParam String branchCode) {
        Map<String, Object> response = new HashMap<>();
        response.put("withdrawalId", "BRN" + System.currentTimeMillis());
        response.put("status", "COMPLETED");
        response.put("type", "BRANCH");
        response.put("amount", amount);
        response.put("accountId", accountId);
        response.put("branchCode", branchCode);
        return response;
    }
}
