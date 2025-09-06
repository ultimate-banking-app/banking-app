package com.banking.account.service;

import com.banking.account.entity.Account;
import com.banking.account.entity.Transaction;
import com.banking.account.repository.AccountRepository;
import com.banking.account.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class AccountService {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    public List<Account> getAllAccounts() {
        return accountRepository.findAll();
    }

    public Account getAccountById(String id) {
        return accountRepository.findById(id).orElse(null);
    }

    public List<Account> getAccountsByUserId(String userId) {
        return accountRepository.findByUserId(userId);
    }

    public List<Transaction> getAllTransactions() {
        return transactionRepository.findAll();
    }

    public List<Transaction> getTransactionsByAccountId(String accountId) {
        return transactionRepository.findByAccountIdOrderByCreatedAtDesc(accountId);
    }

    public Account createAccount(Account account) {
        if (account.getId() == null) {
            account.setId(UUID.randomUUID().toString());
        }
        return accountRepository.save(account);
    }
}
