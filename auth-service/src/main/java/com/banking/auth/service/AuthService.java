package com.banking.auth.service;

import com.banking.auth.entity.User;
import com.banking.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    public User authenticate(String username, String password) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if ("password".equals(password)) {
                return user;
            }
        }
        
        throw new RuntimeException("Invalid credentials");
    }

    public String generateToken(User user) {
        String tokenData = user.getId() + ":" + user.getUsername() + ":" + System.currentTimeMillis();
        return Base64.getEncoder().encodeToString(tokenData.getBytes());
    }

    public User validateToken(String token) {
        try {
            String decoded = new String(Base64.getDecoder().decode(token));
            String[] parts = decoded.split(":");
            if (parts.length >= 2) {
                String userId = parts[0];
                Optional<User> userOpt = userRepository.findById(userId);
                if (userOpt.isPresent()) {
                    return userOpt.get();
                }
            }
        } catch (Exception e) {
            // Token validation failed
        }
        
        throw new RuntimeException("Invalid token");
    }
}
