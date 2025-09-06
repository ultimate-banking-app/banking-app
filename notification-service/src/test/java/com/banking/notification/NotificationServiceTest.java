package com.banking.notification;

import com.banking.notification.entity.Notification;
import com.banking.notification.repository.NotificationRepository;
import com.banking.notification.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationService notificationService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testSendNotification() {
        // Given
        Notification notification = new Notification();
        notification.setUserId("user1");
        notification.setType("DEPOSIT");
        notification.setTitle("Deposit Successful");
        notification.setMessage("Your deposit has been processed");
        
        when(notificationRepository.save(any(Notification.class))).thenReturn(notification);

        // When
        Notification result = notificationService.sendNotification(notification);

        // Then
        assertNotNull(result);
        assertNotNull(result.getId());
        verify(notificationRepository).save(notification);
    }

    @Test
    void testGetNotificationsByUserId() {
        // Given
        String userId = "user1";
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setType("DEPOSIT");
        
        List<Notification> notifications = Arrays.asList(notification);
        when(notificationRepository.findByUserId(userId)).thenReturn(notifications);

        // When
        List<Notification> result = notificationService.getNotificationsByUserId(userId);

        // Then
        assertEquals(1, result.size());
        assertEquals(userId, result.get(0).getUserId());
        verify(notificationRepository).findByUserId(userId);
    }

    @Test
    void testGetAllNotifications() {
        // Given
        Notification notification = new Notification();
        notification.setType("DEPOSIT");
        
        List<Notification> notifications = Arrays.asList(notification);
        when(notificationRepository.findAll()).thenReturn(notifications);

        // When
        List<Notification> result = notificationService.getAllNotifications();

        // Then
        assertEquals(1, result.size());
        verify(notificationRepository).findAll();
    }
}
