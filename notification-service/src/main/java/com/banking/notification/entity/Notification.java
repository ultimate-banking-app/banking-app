package com.banking.notification.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {
    @Id
    private String id;
    
    @Column(name = "user_id")
    private String userId;
    
    @Column(name = "type")
    private String type;
    
    @Column(name = "title")
    private String title;
    
    @Column(name = "message")
    private String message;
    
    @Column(name = "channel")
    private String channel = "EMAIL";
    
    @Column(name = "status")
    private String status = "SENT";
    
    @Column(name = "sent_at")
    private LocalDateTime sentAt;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public Notification() {
        this.createdAt = LocalDateTime.now();
        this.sentAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getChannel() { return channel; }
    public void setChannel(String channel) { this.channel = channel; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
