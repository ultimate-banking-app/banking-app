package com.banking.withdrawal;

import com.banking.withdrawal.entity.Withdrawal;
import com.banking.withdrawal.repository.WithdrawalRepository;
import com.banking.withdrawal.service.WithdrawalService;
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

class WithdrawalServiceTest {

    @Mock
    private WithdrawalRepository withdrawalRepository;

    @InjectMocks
    private WithdrawalService withdrawalService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateWithdrawal() {
        // Given
        Withdrawal withdrawal = new Withdrawal();
        withdrawal.setAccountId("acc1");
        withdrawal.setAmount(new BigDecimal("50.00"));
        withdrawal.setWithdrawalMethod("ATM");
        
        when(withdrawalRepository.save(any(Withdrawal.class))).thenReturn(withdrawal);

        // When
        Withdrawal result = withdrawalService.createWithdrawal(withdrawal);

        // Then
        assertNotNull(result);
        assertNotNull(result.getId());
        verify(withdrawalRepository).save(withdrawal);
    }

    @Test
    void testGetWithdrawalsByAccountId() {
        // Given
        String accountId = "acc1";
        Withdrawal withdrawal = new Withdrawal();
        withdrawal.setAccountId(accountId);
        withdrawal.setAmount(new BigDecimal("50.00"));
        
        List<Withdrawal> withdrawals = Arrays.asList(withdrawal);
        when(withdrawalRepository.findByAccountId(accountId)).thenReturn(withdrawals);

        // When
        List<Withdrawal> result = withdrawalService.getWithdrawalsByAccountId(accountId);

        // Then
        assertEquals(1, result.size());
        assertEquals(accountId, result.get(0).getAccountId());
        verify(withdrawalRepository).findByAccountId(accountId);
    }

    @Test
    void testGetAllWithdrawals() {
        // Given
        Withdrawal withdrawal = new Withdrawal();
        withdrawal.setAccountId("acc1");
        withdrawal.setAmount(new BigDecimal("50.00"));
        
        List<Withdrawal> withdrawals = Arrays.asList(withdrawal);
        when(withdrawalRepository.findAll()).thenReturn(withdrawals);

        // When
        List<Withdrawal> result = withdrawalService.getAllWithdrawals();

        // Then
        assertEquals(1, result.size());
        verify(withdrawalRepository).findAll();
    }
}
