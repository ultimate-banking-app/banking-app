package com.banking.account.service;

import com.banking.shared.entity.Account;
import com.banking.shared.enums.AccountStatus;
import com.banking.shared.enums.AccountType;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AccountService {
    
    private Map<String, Account> accounts = new HashMap<>();

    public Account createAccount(String userId, AccountType accountType, String currency) {
        Account account = new Account(userId, accountType, currency);
        account.setId(UUID.randomUUID().toString());
        account.setAccountNumber(generateAccountNumber());
        accounts.put(account.getId(), account);
        return account;
    }

    public Account getAccountById(String accountId) {
        return accounts.get(accountId);
    }

    public List<Account> getAccountsByUserId(String userId) {
        return accounts.values().stream()
                .filter(account -> account.getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    public Account updateAccountStatus(String accountId, String status) {
        Account account = accounts.get(accountId);
        if (account != null) {
            account.setStatus(AccountStatus.valueOf(status));
        }
        return account;
    }

    private String generateAccountNumber() {
        return "ACC" + System.currentTimeMillis();
    }
}
