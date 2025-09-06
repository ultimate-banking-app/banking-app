package com.banking.deposit.service;

import com.banking.deposit.entity.Deposit;
import com.banking.deposit.repository.DepositRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class DepositService {

    @Autowired
    private DepositRepository depositRepository;

    public Deposit createDeposit(Deposit deposit) {
        if (deposit.getId() == null) {
            deposit.setId(UUID.randomUUID().toString());
        }
        return depositRepository.save(deposit);
    }

    public List<Deposit> getDeposits(String accountId) {
        if (accountId != null) {
            return depositRepository.findByAccountId(accountId);
        }
        return depositRepository.findAll();
    }

    public Deposit getDeposit(String id) {
        return depositRepository.findById(id).orElse(null);
    }
}
