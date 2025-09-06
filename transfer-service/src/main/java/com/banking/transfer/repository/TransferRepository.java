package com.banking.transfer.repository;

import com.banking.transfer.entity.Transfer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransferRepository extends JpaRepository<Transfer, String> {
    List<Transfer> findByFromAccount(String fromAccount);
    List<Transfer> findByToAccount(String toAccount);
}
