package com.banking.transfer;

import com.banking.transfer.entity.Transfer;
import com.banking.transfer.repository.TransferRepository;
import com.banking.transfer.service.TransferService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class TransferServiceTest {

    @Mock
    private TransferRepository transferRepository;

    @InjectMocks
    private TransferService transferService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateTransfer() {
        // Given
        Transfer transfer = new Transfer();
        transfer.setFromAccount("acc1");
        transfer.setToAccount("acc2");
        transfer.setAmount(new BigDecimal("100.00"));
        
        when(transferRepository.save(any(Transfer.class))).thenReturn(transfer);

        // When
        Transfer result = transferService.createTransfer(transfer);

        // Then
        assertNotNull(result);
        assertNotNull(result.getId());
        verify(transferRepository).save(transfer);
    }

    @Test
    void testGetTransfersByFromAccount() {
        // Given
        String fromAccount = "acc1";
        Transfer transfer = new Transfer();
        transfer.setFromAccount(fromAccount);
        transfer.setToAccount("acc2");
        transfer.setAmount(new BigDecimal("100.00"));
        
        List<Transfer> transfers = Arrays.asList(transfer);
        when(transferRepository.findByFromAccount(fromAccount)).thenReturn(transfers);

        // When
        List<Transfer> result = transferService.getTransfersByFromAccount(fromAccount);

        // Then
        assertEquals(1, result.size());
        assertEquals(fromAccount, result.get(0).getFromAccount());
        verify(transferRepository).findByFromAccount(fromAccount);
    }

    @Test
    void testGetAllTransfers() {
        // Given
        Transfer transfer = new Transfer();
        transfer.setFromAccount("acc1");
        transfer.setToAccount("acc2");
        
        List<Transfer> transfers = Arrays.asList(transfer);
        when(transferRepository.findAll()).thenReturn(transfers);

        // When
        List<Transfer> result = transferService.getAllTransfers();

        // Then
        assertEquals(1, result.size());
        verify(transferRepository).findAll();
    }
}
