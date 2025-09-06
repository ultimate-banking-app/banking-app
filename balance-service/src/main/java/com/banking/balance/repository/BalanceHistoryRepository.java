package com.banking.balance.repository;

import com.banking.balance.entity.BalanceHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BalanceHistoryRepository extends JpaRepository<BalanceHistory, String> {
    List<BalanceHistory> findByAccountIdOrderByCreatedAtDesc(String accountId);
    BalanceHistory findTopByAccountIdOrderByCreatedAtDesc(String accountId);
}
