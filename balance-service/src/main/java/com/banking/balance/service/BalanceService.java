package com.banking.balance.service;

import com.banking.balance.entity.BalanceHistory;
import com.banking.balance.repository.BalanceHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class BalanceService {

    @Autowired
    private BalanceHistoryRepository balanceHistoryRepository;

    private final RestTemplate restTemplate = new RestTemplate();

    public BigDecimal getCurrentBalance(String accountId) {
        try {
            // Call account service to get current balance
            String url = "http://localhost:8084/api/accounts/" + accountId;
            Map<String, Object> account = restTemplate.getForObject(url, Map.class);
            if (account != null && account.containsKey("balance")) {
                return new BigDecimal(account.get("balance").toString());
            }
        } catch (Exception e) {
            // Fallback: get latest balance from history
            BalanceHistory latest = balanceHistoryRepository.findTopByAccountIdOrderByCreatedAtDesc(accountId);
            if (latest != null) {
                return latest.getNewBalance();
            }
        }
        return BigDecimal.ZERO;
    }

    public List<BalanceHistory> getBalanceHistory(String accountId) {
        return balanceHistoryRepository.findByAccountIdOrderByCreatedAtDesc(accountId);
    }

    public BalanceHistory updateBalance(String accountId, BigDecimal changeAmount, String changeType, String referenceId) {
        BigDecimal currentBalance = getCurrentBalance(accountId);
        BigDecimal newBalance = currentBalance.add(changeAmount);

        BalanceHistory history = new BalanceHistory();
        history.setId(UUID.randomUUID().toString());
        history.setAccountId(accountId);
        history.setPreviousBalance(currentBalance);
        history.setNewBalance(newBalance);
        history.setChangeAmount(changeAmount);
        history.setChangeType(changeType);
        history.setReferenceId(referenceId);

        return balanceHistoryRepository.save(history);
    }
}
