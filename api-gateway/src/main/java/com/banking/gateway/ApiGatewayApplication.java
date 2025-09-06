package com.banking.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class ApiGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("auth-service", r -> r.path("/api/auth/**")
                        .uri("http://localhost:8081"))
                .route("account-service", r -> r.path("/api/accounts/**")
                        .uri("http://localhost:8082"))
                .route("payment-service", r -> r.path("/api/payments/**")
                        .uri("http://localhost:8083"))
                .route("balance-service", r -> r.path("/api/balance/**")
                        .uri("http://localhost:8084"))
                .route("transfer-service", r -> r.path("/api/transfers/**")
                        .uri("http://localhost:8085"))
                .route("deposit-service", r -> r.path("/api/deposits/**")
                        .uri("http://localhost:8086"))
                .route("withdrawal-service", r -> r.path("/api/withdrawals/**")
                        .uri("http://localhost:8087"))
                .route("notification-service", r -> r.path("/api/notifications/**")
                        .uri("http://localhost:8088"))
                .route("audit-service", r -> r.path("/api/audit/**")
                        .uri("http://localhost:8089"))
                .build();
    }
}
