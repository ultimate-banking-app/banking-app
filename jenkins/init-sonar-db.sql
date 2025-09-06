-- Initialize SonarQube database
CREATE DATABASE sonarqube;
CREATE USER sonarqube WITH ENCRYPTED PASSWORD 'sonarqube';
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
