package com.banking.account.repository;

import com.banking.account.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, String> {
    List<Transaction> findByAccountIdOrderByCreatedAtDesc(String accountId);
}
