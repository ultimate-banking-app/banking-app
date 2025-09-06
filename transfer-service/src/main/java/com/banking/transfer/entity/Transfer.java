package com.banking.transfer.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transfers")
public class Transfer {
    @Id
    private String id;
    
    @Column(name = "from_account")
    private String fromAccount;
    
    @Column(name = "to_account")
    private String toAccount;
    
    @Column(name = "amount")
    private BigDecimal amount;
    
    @Column(name = "currency")
    private String currency = "USD";
    
    @Column(name = "transfer_type")
    private String transferType = "INTERNAL";
    
    @Column(name = "reference_number")
    private String referenceNumber;
    
    @Column(name = "status")
    private String status = "COMPLETED";
    
    @Column(name = "description")
    private String description;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public Transfer() {
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getFromAccount() { return fromAccount; }
    public void setFromAccount(String fromAccount) { this.fromAccount = fromAccount; }

    public String getToAccount() { return toAccount; }
    public void setToAccount(String toAccount) { this.toAccount = toAccount; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getTransferType() { return transferType; }
    public void setTransferType(String transferType) { this.transferType = transferType; }

    public String getReferenceNumber() { return referenceNumber; }
    public void setReferenceNumber(String referenceNumber) { this.referenceNumber = referenceNumber; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
