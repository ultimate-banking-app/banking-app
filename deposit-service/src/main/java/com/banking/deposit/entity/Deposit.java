package com.banking.deposit.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "deposits")
public class Deposit {
    @Id
    private String id;
    
    @Column(name = "account_id")
    private String accountId;
    
    @Column(name = "amount")
    private BigDecimal amount;
    
    @Column(name = "currency")
    private String currency = "USD";
    
    @Column(name = "deposit_method")
    private String depositMethod = "WEB";
    
    @Column(name = "reference_number")
    private String referenceNumber;
    
    @Column(name = "status")
    private String status = "COMPLETED";
    
    @Column(name = "description")
    private String description;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public Deposit() {
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getDepositMethod() { return depositMethod; }
    public void setDepositMethod(String depositMethod) { this.depositMethod = depositMethod; }

    public String getReferenceNumber() { return referenceNumber; }
    public void setReferenceNumber(String referenceNumber) { this.referenceNumber = referenceNumber; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
