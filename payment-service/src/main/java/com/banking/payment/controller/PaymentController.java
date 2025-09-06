package com.banking.payment.controller;

import com.banking.payment.entity.Payment;
import com.banking.payment.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    @Autowired
    private PaymentRepository paymentRepository;

    @GetMapping
    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }

    @GetMapping("/{paymentId}")
    public ResponseEntity<Payment> getPayment(@PathVariable String paymentId) {
        Optional<Payment> payment = paymentRepository.findById(paymentId);
        return payment.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/account/{accountNumber}")
    public List<Payment> getPaymentsByAccount(@PathVariable String accountNumber) {
        return paymentRepository.findByFromAccountOrToAccount(accountNumber, accountNumber);
    }

    @PostMapping
    public ResponseEntity<Payment> createPayment(@RequestBody Map<String, Object> request) {
        Payment payment = new Payment();
        payment.setId("pay-" + UUID.randomUUID().toString().substring(0, 8));
        payment.setFromAccount((String) request.get("fromAccount"));
        payment.setToAccount((String) request.get("toAccount"));
        payment.setAmount(new BigDecimal(request.get("amount").toString()));
        payment.setCurrency((String) request.getOrDefault("currency", "USD"));
        payment.setType((String) request.get("type"));
        payment.setStatus("PENDING");
        payment.setDescription((String) request.get("description"));
        
        Payment savedPayment = paymentRepository.save(payment);
        return ResponseEntity.ok(savedPayment);
    }
}
