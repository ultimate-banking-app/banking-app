package com.banking.shared.exception;

public class BankingException extends RuntimeException {
    private String errorCode;

    public BankingException(String message) {
        super(message);
    }

    public BankingException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public String getErrorCode() { return errorCode; }
}
