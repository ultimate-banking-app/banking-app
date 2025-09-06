package com.banking.withdrawal.service;

import com.banking.withdrawal.entity.Withdrawal;
import com.banking.withdrawal.repository.WithdrawalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class WithdrawalService {

    @Autowired
    private WithdrawalRepository withdrawalRepository;

    public Withdrawal createWithdrawal(Withdrawal withdrawal) {
        if (withdrawal.getId() == null) {
            withdrawal.setId(UUID.randomUUID().toString());
        }
        return withdrawalRepository.save(withdrawal);
    }

    public List<Withdrawal> getWithdrawalsByAccountId(String accountId) {
        return withdrawalRepository.findByAccountId(accountId);
    }

    public List<Withdrawal> getAllWithdrawals() {
        return withdrawalRepository.findAll();
    }
}
