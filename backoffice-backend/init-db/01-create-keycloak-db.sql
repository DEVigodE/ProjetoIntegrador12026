-- Cria o banco de dados e o usuário para o Keycloak
CREATE USER keycloak WITH PASSWORD 'keycloak_pass';
CREATE DATABASE keycloak OWNER keycloak;
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
