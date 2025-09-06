package com.banking.notification.controller;

import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @PostMapping("/sms")
    public Map<String, Object> sendSMS(@RequestParam String phoneNumber,
                                     @RequestParam String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("notificationId", "SMS" + System.currentTimeMillis());
        response.put("status", "SENT");
        response.put("type", "SMS");
        response.put("phoneNumber", phoneNumber);
        return response;
    }

    @PostMapping("/email")
    public Map<String, Object> sendEmail(@RequestParam String email,
                                       @RequestParam String subject,
                                       @RequestParam String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("notificationId", "EMAIL" + System.currentTimeMillis());
        response.put("status", "SENT");
        response.put("type", "EMAIL");
        response.put("email", email);
        return response;
    }

    @PostMapping("/push")
    public Map<String, Object> sendPushNotification(@RequestParam String userId,
                                                  @RequestParam String title,
                                                  @RequestParam String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("notificationId", "PUSH" + System.currentTimeMillis());
        response.put("status", "SENT");
        response.put("type", "PUSH");
        response.put("userId", userId);
        return response;
    }
}
