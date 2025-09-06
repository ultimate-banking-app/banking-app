package com.banking.shared.dto;

import java.math.BigDecimal;

public class TransactionRequest {
    private String accountId;
    private BigDecimal amount;
    private String type;
    private String description;

    public TransactionRequest() {}

    public TransactionRequest(String accountId, BigDecimal amount, String type, String description) {
        this.accountId = accountId;
        this.amount = amount;
        this.type = type;
        this.description = description;
    }

    // Getters and Setters
    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
