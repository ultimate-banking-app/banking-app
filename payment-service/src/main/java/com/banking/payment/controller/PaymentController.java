package com.banking.payment.controller;

import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    @PostMapping("/process")
    public Map<String, Object> processPayment(@RequestParam String accountId,
                                            @RequestParam BigDecimal amount,
                                            @RequestParam String payeeId,
                                            @RequestParam String description) {
        Map<String, Object> response = new HashMap<>();
        response.put("transactionId", "TXN" + System.currentTimeMillis());
        response.put("status", "COMPLETED");
        response.put("amount", amount);
        response.put("accountId", accountId);
        response.put("payeeId", payeeId);
        return response;
    }

    @GetMapping("/history/{accountId}")
    public Map<String, Object> getPaymentHistory(@PathVariable String accountId) {
        Map<String, Object> response = new HashMap<>();
        response.put("accountId", accountId);
        response.put("payments", new Object[]{});
        return response;
    }
}
