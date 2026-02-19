# 🔐 Integração com Keycloak

## 1. Introdução

Este documento detalha a integração do sistema de Backoffice para Delivery com o **Keycloak**, um sistema de Identity and Access Management (IAM) open-source que implementa os padrões OAuth 2.0 e OpenID Connect.

---

## 2. Por que Keycloak?

### 2.1 Vantagens

| **Vantagem** | **Descrição** |
|--------------|---------------|
| **Padrões da Indústria** | Implementa OAuth 2.0, OpenID Connect, SAML 2.0 |
| **Redução de Código** | Elimina necessidade de desenvolver auth-service personalizado |
| **Segurança Robusta** | Sistema maduro, testado e auditado pela comunidade |
| **Recursos Prontos** | SSO, Social Login, User Federation, 2FA, etc. |
| **Gestão de Usuários** | Admin Console completo para gerenciar usuários e permissões |
| **Extensibilidade** | SPIs para customizações |
| **Multi-tenancy** | Suporte a múltiplos realms (tenants) |
| **Performance** | Cache integrado, sessões distribuídas |

### 2.2 Comparação com Auth-Service Próprio

| **Aspecto** | **Auth-Service Próprio** | **Keycloak** |
|-------------|-------------------------|--------------|
| Tempo de Desenvolvimento | 2-3 sprints | 1 sprint (configuração) |
| Segurança | Requer expertise, testes extensivos | Já testado e auditado |
| Recursos | Básicos (login, JWT) | Completo (SSO, 2FA, Social Login, etc.) |
| Manutenção | Alta (correções, atualizações) | Baixa (comunidade mantém) |
| Padrões | Custom | OAuth 2.0 / OpenID Connect |
| Admin UI | Precisa desenvolver | Já incluso |

---

## 3. Arquitetura de Integração

### 3.1 Diagrama de Fluxo

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   React     │         │ API Gateway │         │  Keycloak   │
│   Frontend  │         │  (Spring)   │         │   Server    │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       │ 1. Login Request      │                       │
       │──────────────────────────────────────────────>│
       │                       │                       │
       │ 2. Access Token + Refresh Token + ID Token    │
       │<──────────────────────────────────────────────│
       │                       │                       │
       │ 3. API Request        │                       │
       │   + Bearer Token      │                       │
       │──────────────────────>│                       │
       │                       │                       │
       │                       │ 4. Validate Token     │
       │                       │   (verify signature)  │
       │                       │                       │
       │                       │ 5. Extract Claims     │
       │                       │   (userId, roles)     │
       │                       │                       │
       │                       │ 6. Route to Service   │
       │                       │────────>              │
       │                       │                       │
       │ 7. Response           │                       │
       │<──────────────────────│                       │
       │                       │                       │
```

### 3.2 Componentes

#### **Frontend (React)**
- Biblioteca: `keycloak-js` ou `@react-keycloak/web`
- Responsabilidade: Iniciar login, armazenar tokens, renovar tokens automaticamente

#### **API Gateway (Spring Cloud Gateway)**
- Dependência: `spring-boot-starter-oauth2-resource-server`
- Responsabilidade: Validar token JWT, extrair roles, propagar contexto de segurança

#### **Microsserviços**
- Dependência: `spring-boot-starter-oauth2-resource-server` (opcional)
- Responsabilidade: Verificar autorização baseada em roles

#### **Keycloak Server**
- Responsabilidade: Emitir tokens, gerenciar usuários, autenticar

---

## 4. Configuração do Keycloak

### 4.1 Instalação (Docker Compose)

```yaml
version: '3.8'

services:
  postgres-keycloak:
    image: postgres:15
    container_name: keycloak-db
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak_pass
    volumes:
      - keycloak-postgres-data:/var/lib/postgresql/data
    networks:
      - delivery-network

  keycloak:
    image: quay.io/keycloak/keycloak:24.0
    container_name: keycloak
    command: start-dev
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres-keycloak:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak_pass
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
    ports:
      - "8080:8080"
    depends_on:
      - postgres-keycloak
    networks:
      - delivery-network

volumes:
  keycloak-postgres-data:

networks:
  delivery-network:
    driver: bridge
```

**Iniciar**:
```bash
docker-compose up -d
```

**Acessar Admin Console**: `http://localhost:8080`
- Usuário: `admin`
- Senha: `admin`

### 4.2 Configuração do Realm

#### Passo 1: Criar Realm
1. Acessar Admin Console
2. Clicar em **Add realm**
3. Nome: `delivery-backoffice`
4. Clicar em **Create**

#### Passo 2: Criar Client
1. Menu **Clients** > **Create**
2. Configurações:
   - **Client ID**: `backoffice-webapp`
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `public`
   - **Standard Flow Enabled**: `ON`
   - **Direct Access Grants Enabled**: `ON` (para desenvolvimento)
   - **Valid Redirect URIs**: 
     - `http://localhost:3000/*`
     - `https://backoffice.delivery.com/*`
   - **Web Origins**: `*` ou específicos
3. Salvar

#### Passo 3: Criar Roles
1. Menu **Roles** > **Add Role**
2. Criar as seguintes roles:
   - `ADMIN` - Acesso total
   - `OPERATOR` - Gerencia pedidos e produtos
   - `DISPATCHER` - Gerencia entregas

#### Passo 4: Criar Usuários de Teste
1. Menu **Users** > **Add user**
2. **Username**: `admin@delivery.com`
3. **Email**: `admin@delivery.com`
4. **First Name**: `Admin`
5. **Last Name**: `Sistema`
6. **Email Verified**: `ON`
7. Salvar
8. Aba **Credentials** > Definir senha > `admin123` > **Temporary**: `OFF`
9. Aba **Role Mappings** > Atribuir role `ADMIN`

Repetir para outros usuários de teste (operator, dispatcher).

### 4.3 Configuração de Token

1. Menu **Realm Settings** > **Tokens**
2. Configurações recomendadas:
   - **Access Token Lifespan**: `5 minutes`
   - **Access Token Lifespan For Implicit Flow**: `15 minutes`
   - **Client Login Timeout**: `5 minutes`
   - **Refresh Token Max Reuse**: `0`
   - **SSO Session Idle**: `30 minutes`
   - **SSO Session Max**: `10 hours`

---

## 5. Integração Frontend (React)

### 5.1 Instalação

```bash
npm install keycloak-js
# ou
npm install @react-keycloak/web
```

### 5.2 Configuração

**Arquivo: `src/keycloak.js`**
```javascript
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: 'http://localhost:8080',
  realm: 'delivery-backoffice',
  clientId: 'backoffice-webapp'
});

export default keycloak;
```

### 5.3 Inicialização (App.js)

**Opção 1: Usando keycloak-js diretamente**
```javascript
import React, { useEffect, useState } from 'react';
import keycloak from './keycloak';

function App() {
  const [authenticated, setAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    keycloak.init({
      onLoad: 'login-required',
      checkLoginIframe: false
    }).then(authenticated => {
      setAuthenticated(authenticated);
      setLoading(false);
      
      // Configurar refresh token automático
      setInterval(() => {
        keycloak.updateToken(70).then((refreshed) => {
          if (refreshed) {
            console.log('Token was successfully refreshed');
          }
        }).catch(() => {
          console.log('Failed to refresh token');
        });
      }, 60000); // A cada 60 segundos
    });
  }, []);

  if (loading) {
    return <div>Carregando...</div>;
  }

  if (!authenticated) {
    return <div>Não autenticado</div>;
  }

  return (
    <div>
      <h1>Bem-vindo ao Backoffice</h1>
      <p>Usuário: {keycloak.tokenParsed?.preferred_username}</p>
      <p>Roles: {keycloak.realmAccess?.roles.join(', ')}</p>
      <button onClick={() => keycloak.logout()}>Logout</button>
    </div>
  );
}

export default App;
```

**Opção 2: Usando @react-keycloak/web**
```javascript
import React from 'react';
import { ReactKeycloakProvider } from '@react-keycloak/web';
import keycloak from './keycloak';

function App() {
  return (
    <ReactKeycloakProvider authClient={keycloak}>
      <MainApp />
    </ReactKeycloakProvider>
  );
}

function MainApp() {
  const { keycloak, initialized } = useKeycloak();

  if (!initialized) {
    return <div>Carregando...</div>;
  }

  if (!keycloak.authenticated) {
    return <div>Não autenticado</div>;
  }

  return (
    <div>
      <h1>Bem-vindo ao Backoffice</h1>
      <p>Usuário: {keycloak.tokenParsed?.preferred_username}</p>
      <button onClick={() => keycloak.logout()}>Logout</button>
    </div>
  );
}
```

### 5.4 Axios Interceptor (para enviar token)

```javascript
import axios from 'axios';
import keycloak from './keycloak';

const api = axios.create({
  baseURL: 'http://localhost:8081'
});

api.interceptors.request.use(
  config => {
    if (keycloak.token) {
      config.headers.Authorization = `Bearer ${keycloak.token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      try {
        await keycloak.updateToken(30);
        error.config.headers.Authorization = `Bearer ${keycloak.token}`;
        return api.request(error.config);
      } catch (refreshError) {
        keycloak.logout();
      }
    }
    return Promise.reject(error);
  }
);

export default api;
```

### 5.5 Proteção de Rotas

```javascript
import { useKeycloak } from '@react-keycloak/web';
import { Navigate } from 'react-router-dom';

function ProtectedRoute({ children, roles }) {
  const { keycloak, initialized } = useKeycloak();

  if (!initialized) {
    return <div>Carregando...</div>;
  }

  if (!keycloak.authenticated) {
    keycloak.login();
    return null;
  }

  if (roles && !roles.some(role => keycloak.hasRealmRole(role))) {
    return <Navigate to="/unauthorized" />;
  }

  return children;
}

// Uso:
<Route 
  path="/admin" 
  element={
    <ProtectedRoute roles={['ADMIN']}>
      <AdminPage />
    </ProtectedRoute>
  } 
/>
```

---

## 6. Integração Backend (Spring Boot)

### 6.1 API Gateway

**pom.xml**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

**application.yml**
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/delivery-backoffice
          jwk-set-uri: http://localhost:8080/realms/delivery-backoffice/protocol/openid-connect/certs

  cloud:
    gateway:
      routes:
        - id: product-service
          uri: lb://product-service
          predicates:
            - Path=/api/products/**
          filters:
            - TokenRelay=
```

**SecurityConfig.java**
```java
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .csrf().disable()
            .authorizeExchange()
                .pathMatchers("/actuator/**").permitAll()
                .pathMatchers("/api/products/**").hasAnyAuthority("ADMIN", "OPERATOR")
                .pathMatchers("/api/orders/**").hasAnyAuthority("ADMIN", "OPERATOR")
                .pathMatchers("/api/delivery/**").hasAnyAuthority("ADMIN", "DISPATCHER")
                .pathMatchers("/api/reports/**").hasAuthority("ADMIN")
                .anyExchange().authenticated()
            .and()
            .oauth2ResourceServer()
                .jwt();
        
        return http.build();
    }

    @Bean
    public ReactiveJwtDecoder jwtDecoder() {
        return ReactiveJwtDecoders.fromIssuerLocation(
            "http://localhost:8080/realms/delivery-backoffice"
        );
    }

    @Bean
    public Converter<Jwt, Mono<AbstractAuthenticationToken>> jwtAuthenticationConverter() {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(new KeycloakRoleConverter());
        return new ReactiveJwtAuthenticationConverterAdapter(converter);
    }
}
```

**KeycloakRoleConverter.java**
```java
public class KeycloakRoleConverter implements Converter<Jwt, Collection<GrantedAuthority>> {

    @Override
    public Collection<GrantedAuthority> convert(Jwt jwt) {
        Map<String, Object> realmAccess = jwt.getClaim("realm_access");
        
        if (realmAccess == null || realmAccess.get("roles") == null) {
            return Collections.emptyList();
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) realmAccess.get("roles");
        
        return roles.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
    }
}
```

### 6.2 Microsserviços (Product, Order, etc.)

**application.yml**
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://keycloak:8080/realms/delivery-backoffice
          jwk-set-uri: http://keycloak:8080/realms/delivery-backoffice/protocol/openid-connect/certs
```

**SecurityConfig.java**
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt
                    .jwtAuthenticationConverter(jwtAuthenticationConverter())
                )
            );
        
        return http.build();
    }

    private Converter<Jwt, AbstractAuthenticationToken> jwtAuthenticationConverter() {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(new KeycloakRoleConverter());
        return converter;
    }
}
```

**Uso em Controllers**
```java
@RestController
@RequestMapping("/api/products")
public class ProductController {

    @GetMapping
    @PreAuthorize("hasAnyAuthority('ADMIN', 'OPERATOR')")
    public List<Product> listProducts() {
        return productService.findAll();
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    public Product createProduct(@RequestBody ProductDTO dto) {
        return productService.create(dto);
    }

    @GetMapping("/me")
    public UserInfo getCurrentUser(Authentication authentication) {
        Jwt jwt = (Jwt) authentication.getPrincipal();
        return UserInfo.builder()
            .username(jwt.getClaim("preferred_username"))
            .email(jwt.getClaim("email"))
            .roles(jwt.getClaimAsStringList("realm_access.roles"))
            .build();
    }
}
```

---

## 7. Fluxos de Autenticação

### 7.1 Authorization Code Flow (Recomendado para SPA)

1. Usuário acessa aplicação
2. Frontend redireciona para Keycloak
3. Usuário faz login no Keycloak
4. Keycloak redireciona de volta com código de autorização
5. Frontend troca código por tokens (Access, Refresh, ID)
6. Frontend armazena tokens (memória, não localStorage por segurança)
7. Frontend usa Access Token nas requisições

### 7.2 Refresh Token Flow

1. Access Token expira
2. Frontend detecta 401
3. Frontend usa Refresh Token para obter novo Access Token
4. Se Refresh Token também expirou, redireciona para login

### 7.3 Logout

1. Usuário clica em logout
2. Frontend chama `keycloak.logout()`
3. Keycloak invalida sessão
4. Usuário é redirecionado para tela de login

---

## 8. Testes

### 8.1 Obter Token via cURL (Direct Access Grant)

```bash
curl -X POST http://localhost:8080/realms/delivery-backoffice/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=backoffice-webapp" \
  -d "username=admin@delivery.com" \
  -d "password=admin123" \
  -d "grant_type=password"
```

**Resposta**:
```json
{
  "access_token": "eyJhbGc...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "refresh_token": "eyJhbGc...",
  "token_type": "Bearer",
  "id_token": "eyJhbGc...",
  "not-before-policy": 0,
  "session_state": "abc-123",
  "scope": "openid profile email"
}
```

### 8.2 Fazer Requisição Autenticada

```bash
curl -X GET http://localhost:8081/api/products \
  -H "Authorization: Bearer eyJhbGc..."
```

### 8.3 Verificar Token (Introspection)

```bash
curl -X POST http://localhost:8080/realms/delivery-backoffice/protocol/openid-connect/token/introspect \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=backoffice-webapp" \
  -d "token=eyJhbGc..."
```

---

## 9. Ambientes

### 9.1 Desenvolvimento

- URL Keycloak: `http://localhost:8080`
- Realm: `delivery-backoffice`
- Facilitar testes com Direct Access Grants habilitado

### 9.2 Produção

- URL Keycloak: `https://keycloak.delivery.com`
- Realm: `delivery-backoffice`
- Desabilitar Direct Access Grants
- Configurar HTTPS obrigatório
- Configurar CORS adequadamente
- Habilitar 2FA para admin
- Backup regular do banco de dados do Keycloak

---

## 10. Melhores Práticas

### 10.1 Segurança

✅ **Usar HTTPS em produção**
✅ **Access Token com TTL curto (5 min)**
✅ **Refresh Token com TTL moderado (30 min)**
✅ **Não armazenar tokens em localStorage** (risco XSS)
✅ **Validar tokens no Gateway e opcional nos serviços**
✅ **Implementar rate limiting**
✅ **Habilitar 2FA para usuários críticos**

### 10.2 Performance

✅ **Cache de chaves públicas (JWK)**
✅ **Validação local de JWT (sem chamar Keycloak)**
✅ **Usar Redis para sessões distribuídas do Keycloak**

### 10.3 Monitoramento

✅ **Monitorar eventos de login/logout no Keycloak**
✅ **Alertar sobre tentativas de login falhas**
✅ **Dashboard de usuários ativos**
✅ **Logs de auditoria**

---

## 11. Troubleshooting

### 11.1 Erro: "CORS error"

**Solução**: Configurar Web Origins no client do Keycloak:
- `http://localhost:3000`
- `https://backoffice.delivery.com`

### 11.2 Erro: "Invalid token signature"

**Possíveis causas**:
- URL do issuer incorreta
- Clock skew entre servidores
- Token expirado

**Solução**: Verificar configuração `issuer-uri` e sincronizar relógios (NTP).

### 11.3 Erro: "Role not found"

**Solução**: Criar role no Keycloak e atribuir ao usuário.

### 11.4 Token não tem roles

**Solução**: Verificar se roles estão sendo incluídas no token:
1. Client > Mappers > Create
2. Mapper Type: `User Realm Role`
3. Token Claim Name: `realm_access.roles`

---

## 12. Referências

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [Spring Security OAuth2](https://spring.io/projects/spring-security-oauth)
- [keycloak-js Documentation](https://www.keycloak.org/docs/latest/securing_apps/#_javascript_adapter)

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
