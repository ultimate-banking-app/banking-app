package com.banking.balance.controller;

import com.banking.balance.entity.BalanceHistory;
import com.banking.balance.service.BalanceService;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/balance")
@CrossOrigin(origins = "*")
public class BalanceController {

    @Autowired
    private BalanceService balanceService;
    
    private final Counter balanceRequestsCounter;

    public BalanceController(MeterRegistry meterRegistry) {
        this.balanceRequestsCounter = Counter.builder("banking_balance_requests_total")
            .description("Total balance requests")
            .tag("service", "balance")
            .register(meterRegistry);
    }

    @GetMapping("/{accountId}")
    public ResponseEntity<BigDecimal> getBalance(@PathVariable String accountId) {
        balanceRequestsCounter.increment();
        BigDecimal balance = balanceService.getCurrentBalance(accountId);
        return ResponseEntity.ok(balance);
    }

    @GetMapping("/{accountId}/history")
    public ResponseEntity<List<BalanceHistory>> getBalanceHistory(@PathVariable String accountId) {
        balanceRequestsCounter.increment();
        List<BalanceHistory> history = balanceService.getBalanceHistory(accountId);
        return ResponseEntity.ok(history);
    }

    @PostMapping("/update")
    public ResponseEntity<BalanceHistory> updateBalance(@RequestBody BalanceUpdateRequest request) {
        balanceRequestsCounter.increment();
        BalanceHistory history = balanceService.updateBalance(
            request.getAccountId(),
            request.getChangeAmount(),
            request.getChangeType(),
            request.getReferenceId()
        );
        return ResponseEntity.ok(history);
    }

    public static class BalanceUpdateRequest {
        private String accountId;
        private BigDecimal changeAmount;
        private String changeType;
        private String referenceId;

        // Getters and setters
        public String getAccountId() { return accountId; }
        public void setAccountId(String accountId) { this.accountId = accountId; }
        public BigDecimal getChangeAmount() { return changeAmount; }
        public void setChangeAmount(BigDecimal changeAmount) { this.changeAmount = changeAmount; }
        public String getChangeType() { return changeType; }
        public void setChangeType(String changeType) { this.changeType = changeType; }
        public String getReferenceId() { return referenceId; }
        public void setReferenceId(String referenceId) { this.referenceId = referenceId; }
    }
}
