package com.banking.transfer.controller;

import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/transfers")
public class TransferController {

    @PostMapping("/domestic")
    public Map<String, Object> domesticTransfer(@RequestParam String fromAccountId,
                                              @RequestParam String toAccountId,
                                              @RequestParam BigDecimal amount,
                                              @RequestParam String description) {
        Map<String, Object> response = new HashMap<>();
        response.put("transferId", "TRF" + System.currentTimeMillis());
        response.put("status", "COMPLETED");
        response.put("type", "DOMESTIC");
        response.put("amount", amount);
        response.put("fromAccountId", fromAccountId);
        response.put("toAccountId", toAccountId);
        return response;
    }

    @PostMapping("/international")
    public Map<String, Object> internationalTransfer(@RequestParam String fromAccountId,
                                                   @RequestParam String toAccountNumber,
                                                   @RequestParam String swiftCode,
                                                   @RequestParam BigDecimal amount,
                                                   @RequestParam String currency) {
        Map<String, Object> response = new HashMap<>();
        response.put("transferId", "INTL" + System.currentTimeMillis());
        response.put("status", "PROCESSING");
        response.put("type", "INTERNATIONAL");
        response.put("amount", amount);
        response.put("currency", currency);
        response.put("estimatedDays", "3-5");
        return response;
    }
}
