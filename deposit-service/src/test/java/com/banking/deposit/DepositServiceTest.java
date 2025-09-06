package com.banking.deposit;

import com.banking.deposit.entity.Deposit;
import com.banking.deposit.repository.DepositRepository;
import com.banking.deposit.service.DepositService;
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

class DepositServiceTest {

    @Mock
    private DepositRepository depositRepository;

    @InjectMocks
    private DepositService depositService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateDeposit() {
        // Given
        Deposit deposit = new Deposit();
        deposit.setAccountId("acc1");
        deposit.setAmount(new BigDecimal("100.00"));
        
        when(depositRepository.save(any(Deposit.class))).thenReturn(deposit);

        // When
        Deposit result = depositService.createDeposit(deposit);

        // Then
        assertNotNull(result);
        verify(depositRepository).save(deposit);
    }

    @Test
    void testGetDeposits() {
        // Given
        Deposit deposit = new Deposit();
        deposit.setAccountId("acc1");
        deposit.setAmount(new BigDecimal("100.00"));
        
        List<Deposit> deposits = Arrays.asList(deposit);
        when(depositRepository.findByAccountId("acc1")).thenReturn(deposits);

        // When
        List<Deposit> result = depositService.getDeposits("acc1");

        // Then
        assertEquals(1, result.size());
        verify(depositRepository).findByAccountId("acc1");
    }
}
