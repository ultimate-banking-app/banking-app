package com.banking.balance.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "balance_history")
public class BalanceHistory {
    @Id
    private String id;
    
    @Column(name = "account_id")
    private String accountId;
    
    @Column(name = "previous_balance")
    private BigDecimal previousBalance;
    
    @Column(name = "new_balance")
    private BigDecimal newBalance;
    
    @Column(name = "change_amount")
    private BigDecimal changeAmount;
    
    @Column(name = "change_type")
    private String changeType;
    
    @Column(name = "reference_id")
    private String referenceId;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Constructors
    public BalanceHistory() {
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public BigDecimal getPreviousBalance() { return previousBalance; }
    public void setPreviousBalance(BigDecimal previousBalance) { this.previousBalance = previousBalance; }

    public BigDecimal getNewBalance() { return newBalance; }
    public void setNewBalance(BigDecimal newBalance) { this.newBalance = newBalance; }

    public BigDecimal getChangeAmount() { return changeAmount; }
    public void setChangeAmount(BigDecimal changeAmount) { this.changeAmount = changeAmount; }

    public String getChangeType() { return changeType; }
    public void setChangeType(String changeType) { this.changeType = changeType; }

    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
