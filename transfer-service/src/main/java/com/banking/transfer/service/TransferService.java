package com.banking.transfer.service;

import com.banking.transfer.entity.Transfer;
import com.banking.transfer.repository.TransferRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class TransferService {

    @Autowired
    private TransferRepository transferRepository;

    public Transfer createTransfer(Transfer transfer) {
        if (transfer.getId() == null) {
            transfer.setId(UUID.randomUUID().toString());
        }
        return transferRepository.save(transfer);
    }

    public List<Transfer> getTransfersByFromAccount(String fromAccount) {
        return transferRepository.findByFromAccount(fromAccount);
    }

    public List<Transfer> getTransfersByToAccount(String toAccount) {
        return transferRepository.findByToAccount(toAccount);
    }

    public List<Transfer> getAllTransfers() {
        return transferRepository.findAll();
    }
}
