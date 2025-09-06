package com.banking.shared.exception;

public class InsufficientFundsException extends BankingException {
    public InsufficientFundsException() {
        super("INSUFFICIENT_FUNDS", "Insufficient funds for this transaction");
    }
}
