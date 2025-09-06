package com.banking.payment.repository;

import com.banking.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {
    List<Payment> findByFromAccount(String fromAccount);
    List<Payment> findByToAccount(String toAccount);
    List<Payment> findByFromAccountOrToAccount(String fromAccount, String toAccount);
}
