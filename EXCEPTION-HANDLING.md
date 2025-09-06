# Exception Handling - Banking Application

## 🛡️ Exception Handling Strategy

### Core Components
- **Custom Exceptions**: Banking-specific exceptions in shared module
- **Global Handler**: Centralized exception handling with `@RestControllerAdvice`
- **Consistent Responses**: All errors return `ApiResponse<String>` format

## 📦 Exception Hierarchy

### Base Exception
```java
BankingException extends RuntimeException
- errorCode: String
- message: String
```

### Specific Exceptions
- **AccountNotFoundException**: When account ID not found
- **InsufficientFundsException**: When balance is insufficient
- **BankingException**: Generic banking operation errors

## 🔧 Implementation

### Global Exception Handler
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BankingException.class)
    @ExceptionHandler(AccountNotFoundException.class)
    @ExceptionHandler(InsufficientFundsException.class)
    @ExceptionHandler(Exception.class)
}
```

### Service Layer
```java
// Throws specific exceptions
throw new AccountNotFoundException(accountId);
throw new InsufficientFundsException();
throw new BankingException("ERROR_CODE", "Error message");
```

### Controller Layer
```java
// Returns consistent ApiResponse format
return ResponseEntity.ok(ApiResponse.success(data));
// Exceptions automatically handled by GlobalExceptionHandler
```

## 📊 Error Response Format

### Success Response
```json
{
  "success": true,
  "message": "Success",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Account not found: acc123",
  "data": null
}
```

## 🎯 HTTP Status Codes

- **200 OK**: Successful operations
- **400 Bad Request**: Business logic errors (insufficient funds, invalid data)
- **404 Not Found**: Resource not found (account, user)
- **500 Internal Server Error**: Unexpected system errors

## ✅ Services Updated

### With Exception Handling
- ✅ **Auth Service**: Invalid credentials, token errors
- ✅ **Account Service**: Account not found, database errors

### To Be Updated
- ⏳ **Audit Service**: Audit log errors
- ⏳ **Balance Service**: Balance calculation errors
- ⏳ **Transfer Service**: Transfer validation errors
- ⏳ **Deposit/Withdrawal**: Transaction errors

## 🚀 Usage Examples

### Service Layer
```java
public Account getAccountById(String id) {
    return accountRepository.findById(id)
            .orElseThrow(() -> new AccountNotFoundException(id));
}
```

### Controller Layer
```java
@GetMapping("/{id}")
public ResponseEntity<ApiResponse<Account>> getAccount(@PathVariable String id) {
    Account account = accountService.getAccountById(id);
    return ResponseEntity.ok(ApiResponse.success(account));
}
```

## 🔍 Testing Exception Handling

### Test Invalid Account
```bash
curl -X GET http://localhost:8084/api/accounts/invalid-id
# Returns: 404 with error message
```

### Test Invalid Login
```bash
curl -X POST http://localhost:8081/api/auth/login \
  -d '{"username":"invalid","password":"wrong"}'
# Returns: 400 with error message
```
