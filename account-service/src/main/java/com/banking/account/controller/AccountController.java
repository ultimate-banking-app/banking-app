package com.banking.account.controller;

import com.banking.shared.entity.Account;
import com.banking.shared.enums.AccountType;
import com.banking.account.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    @Autowired
    private AccountService accountService;

    @PostMapping("/create")
    public ResponseEntity<Account> createAccount(@RequestParam String userId, 
                                               @RequestParam AccountType accountType,
                                               @RequestParam(defaultValue = "USD") String currency) {
        Account account = accountService.createAccount(userId, accountType, currency);
        return ResponseEntity.ok(account);
    }

    @GetMapping("/{accountId}")
    public ResponseEntity<Account> getAccount(@PathVariable String accountId) {
        Account account = accountService.getAccountById(accountId);
        return account != null ? ResponseEntity.ok(account) : ResponseEntity.notFound().build();
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Account>> getAccountsByUserId(@PathVariable String userId) {
        List<Account> accounts = accountService.getAccountsByUserId(userId);
        return ResponseEntity.ok(accounts);
    }

    @PatchMapping("/{accountId}/status")
    public ResponseEntity<Account> updateAccountStatus(@PathVariable String accountId, 
                                                     @RequestParam String status) {
        Account account = accountService.updateAccountStatus(accountId, status);
        return account != null ? ResponseEntity.ok(account) : ResponseEntity.notFound().build();
    }
}
