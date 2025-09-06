package com.banking.auth.controller;

import com.banking.auth.entity.User;
import com.banking.auth.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> credentials) {
        String username = credentials.get("username");
        String password = credentials.get("password");
        
        User user = authService.authenticate(username, password);
        String token = authService.generateToken(user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("username", user.getUsername());
        userInfo.put("firstName", user.getFirstName());
        userInfo.put("lastName", user.getLastName());
        userInfo.put("email", user.getEmail());
        userInfo.put("role", user.getRole());
        
        response.put("user", userInfo);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateToken(@RequestHeader("Authorization") String token) {
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        
        User user = authService.validateToken(token);
        
        Map<String, Object> response = new HashMap<>();
        response.put("valid", true);
        response.put("user", user);
        
        return ResponseEntity.ok(response);
    }
}
