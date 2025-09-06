package com.banking.deposit.controller;

import com.banking.deposit.entity.Deposit;
import com.banking.deposit.service.DepositService;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/deposits")
@CrossOrigin(origins = "*")
public class DepositController {

    @Autowired
    private DepositService depositService;
    
    private final Counter depositRequestsCounter;

    public DepositController(MeterRegistry meterRegistry) {
        this.depositRequestsCounter = Counter.builder("banking_deposit_requests_total")
            .description("Total deposit requests")
            .tag("service", "deposit")
            .register(meterRegistry);
    }

    @PostMapping
    public ResponseEntity<Deposit> createDeposit(@RequestBody Deposit deposit) {
        depositRequestsCounter.increment();
        Deposit created = depositService.createDeposit(deposit);
        return ResponseEntity.ok(created);
    }

    @GetMapping
    public ResponseEntity<List<Deposit>> getDeposits(@RequestParam(required = false) String accountId) {
        depositRequestsCounter.increment();
        List<Deposit> deposits = depositService.getDeposits(accountId);
        return ResponseEntity.ok(deposits);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Deposit> getDeposit(@PathVariable String id) {
        depositRequestsCounter.increment();
        Deposit deposit = depositService.getDeposit(id);
        return ResponseEntity.ok(deposit);
    }
}
