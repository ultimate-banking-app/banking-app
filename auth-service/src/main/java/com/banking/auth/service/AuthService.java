package com.banking.auth.service;

import com.banking.auth.dto.LoginRequest;
import com.banking.auth.dto.RegisterRequest;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {
    
    private Map<String, Object> users = new HashMap<>();

    public Map<String, Object> register(RegisterRequest request) {
        Map<String, Object> user = new HashMap<>();
        user.put("id", System.currentTimeMillis());
        user.put("email", request.getEmail());
        user.put("firstName", request.getFirstName());
        user.put("lastName", request.getLastName());
        user.put("phoneNumber", request.getPhoneNumber());
        
        users.put(request.getEmail(), user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("token", "jwt-token-" + System.currentTimeMillis());
        response.put("user", user);
        return response;
    }

    public Map<String, Object> login(LoginRequest request) {
        Map<String, Object> response = new HashMap<>();
        response.put("token", "jwt-token-" + System.currentTimeMillis());
        response.put("user", users.get(request.getEmail()));
        return response;
    }

    public Map<String, Object> verifyToken(String token) {
        Map<String, Object> response = new HashMap<>();
        response.put("valid", true);
        response.put("userId", "user-123");
        return response;
    }
}
