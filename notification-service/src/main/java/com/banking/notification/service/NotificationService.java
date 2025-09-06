package com.banking.notification.service;

import com.banking.notification.entity.Notification;
import com.banking.notification.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    public Notification sendNotification(Notification notification) {
        if (notification.getId() == null) {
            notification.setId(UUID.randomUUID().toString());
        }
        return notificationRepository.save(notification);
    }

    public List<Notification> getNotificationsByUserId(String userId) {
        return notificationRepository.findByUserId(userId);
    }

    public List<Notification> getAllNotifications() {
        return notificationRepository.findAll();
    }
}
