package com.banking.withdrawal.repository;

import com.banking.withdrawal.entity.Withdrawal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WithdrawalRepository extends JpaRepository<Withdrawal, String> {
    List<Withdrawal> findByAccountId(String accountId);
}
