package com.banking.shared.exception;

public class AccountNotFoundException extends BankingException {
    public AccountNotFoundException(String accountId) {
        super("ACCOUNT_NOT_FOUND", "Account not found: " + accountId);
    }
}
