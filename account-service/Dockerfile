FROM openjdk:17-jre-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8084

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8084/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
