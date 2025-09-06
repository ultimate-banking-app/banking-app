package com.banking.account.controller;

import com.banking.account.entity.Account;
import com.banking.account.entity.Transaction;
import com.banking.account.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/accounts")
@CrossOrigin(origins = "*")
public class AccountController {

    @Autowired
    private AccountService accountService;

    @GetMapping
    public ResponseEntity<List<Account>> getAllAccounts() {
        List<Account> accounts = accountService.getAllAccounts();
        return ResponseEntity.ok(accounts);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Account> getAccount(@PathVariable String id) {
        Account account = accountService.getAccountById(id);
        return ResponseEntity.ok(account);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Account>> getAccountsByUserId(@PathVariable String userId) {
        List<Account> accounts = accountService.getAccountsByUserId(userId);
        return ResponseEntity.ok(accounts);
    }

    @GetMapping("/transactions")
    public ResponseEntity<List<Transaction>> getAllTransactions() {
        List<Transaction> transactions = accountService.getAllTransactions();
        return ResponseEntity.ok(transactions);
    }

    @GetMapping("/{accountId}/transactions")
    public ResponseEntity<List<Transaction>> getTransactionsByAccountId(@PathVariable String accountId) {
        List<Transaction> transactions = accountService.getTransactionsByAccountId(accountId);
        return ResponseEntity.ok(transactions);
    }

    @PostMapping
    public ResponseEntity<Account> createAccount(@RequestBody Account account) {
        Account created = accountService.createAccount(account);
        return ResponseEntity.ok(created);
    }
}
