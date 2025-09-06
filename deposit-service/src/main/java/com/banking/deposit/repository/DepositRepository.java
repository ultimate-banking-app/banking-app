package com.banking.deposit.repository;

import com.banking.deposit.entity.Deposit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DepositRepository extends JpaRepository<Deposit, String> {
    List<Deposit> findByAccountId(String accountId);
}
