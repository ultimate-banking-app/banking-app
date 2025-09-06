package com.banking.gateway.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Enumeration;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class GatewayController {

    @Value("${services.auth.url:http://localhost:8081}")
    private String authServiceUrl;

    @Value("${services.account.url:http://localhost:8084}")
    private String accountServiceUrl;

    @Value("${services.payment.url:http://localhost:8083}")
    private String paymentServiceUrl;

    @Value("${services.audit.url:http://localhost:8085}")
    private String auditServiceUrl;

    @Value("${services.balance.url:http://localhost:8086}")
    private String balanceServiceUrl;

    @Value("${services.deposit.url:http://localhost:8087}")
    private String depositServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    @RequestMapping(value = "/auth/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<String> routeAuth(HttpServletRequest request, @RequestBody(required = false) String body) {
        return routeRequest(authServiceUrl, request, body);
    }

    @RequestMapping(value = "/accounts/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<String> routeAccount(HttpServletRequest request, @RequestBody(required = false) String body) {
        return routeRequest(accountServiceUrl, request, body);
    }

    @RequestMapping(value = "/payments/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<String> routePayment(HttpServletRequest request, @RequestBody(required = false) String body) {
        return routeRequest(paymentServiceUrl, request, body);
    }

    @RequestMapping(value = "/audit/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<String> routeAudit(HttpServletRequest request, @RequestBody(required = false) String body) {
        return routeRequest(auditServiceUrl, request, body);
    }

    @RequestMapping(value = "/balance/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<String> routeBalance(HttpServletRequest request, @RequestBody(required = false) String body) {
        return routeRequest(balanceServiceUrl, request, body);
    }

    @RequestMapping(value = "/deposits/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<String> routeDeposit(HttpServletRequest request, @RequestBody(required = false) String body) {
        return routeRequest(depositServiceUrl, request, body);
    }

    private ResponseEntity<String> routeRequest(String serviceUrl, HttpServletRequest request, String body) {
        try {
            String path = request.getRequestURI().substring("/api".length());
            String targetUrl = serviceUrl + "/api" + path;
            
            if (request.getQueryString() != null) {
                targetUrl += "?" + request.getQueryString();
            }

            HttpHeaders headers = new HttpHeaders();
            Enumeration<String> headerNames = request.getHeaderNames();
            while (headerNames.hasMoreElements()) {
                String headerName = headerNames.nextElement();
                if (!headerName.equalsIgnoreCase("host")) {
                    headers.set(headerName, request.getHeader(headerName));
                }
            }

            HttpEntity<String> entity = new HttpEntity<>(body, headers);
            HttpMethod method = HttpMethod.valueOf(request.getMethod());

            ResponseEntity<String> response = restTemplate.exchange(targetUrl, method, entity, String.class);
            return response;
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("{\"error\":\"Gateway routing failed: " + e.getMessage() + "\"}");
        }
    }
}
