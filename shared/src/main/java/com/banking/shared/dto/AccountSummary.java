package com.banking.shared.dto;

import java.math.BigDecimal;

public class AccountSummary {
    private String accountId;
    private String accountNumber;
    private String accountType;
    private BigDecimal balance;
    private String currency;
    private String status;

    public AccountSummary() {}

    public AccountSummary(String accountId, String accountNumber, String accountType, 
                         BigDecimal balance, String currency, String status) {
        this.accountId = accountId;
        this.accountNumber = accountNumber;
        this.accountType = accountType;
        this.balance = balance;
        this.currency = currency;
        this.status = status;
    }

    // Getters and Setters
    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }

    public String getAccountType() { return accountType; }
    public void setAccountType(String accountType) { this.accountType = accountType; }

    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
