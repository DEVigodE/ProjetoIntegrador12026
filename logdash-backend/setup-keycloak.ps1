# ============================================================
# Script para configurar o Keycloak automaticamente
# Realm      : logdash
# Clients    : logdash-webapp (mobile/app) + backoffice-webapp (Swagger)
# Roles      : ADMIN, OPERATOR, DISPATCHER, CLIENT, COURIER
# Usuarios   : admin / operator / dispatcher / client / courier
# ============================================================
# Uso: .\setup-keycloak.ps1
# ============================================================

$KC_URL      = "http://localhost:8080"
$ADMIN_USER  = "admin"
$ADMIN_PASS  = "admin"
$REALM       = "logdash"

Write-Host "=== Configurando Keycloak (realm: $REALM) ===" -ForegroundColor Cyan

# 1. Obter token de admin do realm master
Write-Host "`n[1/7] Autenticando no realm master..." -ForegroundColor Yellow
$tokenResponse = Invoke-RestMethod `
    -Uri "$KC_URL/realms/master/protocol/openid-connect/token" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body "grant_type=password&client_id=admin-cli&username=$ADMIN_USER&password=$ADMIN_PASS"

$token = $tokenResponse.access_token
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
Write-Host "  OK - Token obtido" -ForegroundColor Green

# 2. Criar Realm
Write-Host "`n[2/7] Criando realm '$REALM'..." -ForegroundColor Yellow
$realmBody = @{
    realm                  = $REALM
    displayName            = "LogDash Delivery"
    enabled                = $true
    loginTheme             = "keycloak"
    accessTokenLifespan    = 1800
    ssoSessionMaxLifespan  = 36000
    registrationAllowed    = $true
    registrationEmailAsUsername = $false
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$KC_URL/admin/realms" -Method Post -Headers $headers -Body $realmBody | Out-Null
    Write-Host "  OK - Realm criado" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "  INFO - Realm ja existe, continuando..." -ForegroundColor DarkYellow
    } else {
        Write-Host "  ERRO: $_" -ForegroundColor Red; exit 1
    }
}

# 3. Criar Roles do realm
Write-Host "`n[3/7] Criando roles (ADMIN, OPERATOR, DISPATCHER, CLIENT, COURIER)..." -ForegroundColor Yellow
foreach ($role in @("ADMIN", "OPERATOR", "DISPATCHER", "CLIENT", "COURIER")) {
    $roleBody = @{ name = $role; description = "Role $role" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/roles" -Method Post -Headers $headers -Body $roleBody | Out-Null
        Write-Host "  OK - Role '$role' criada" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            Write-Host "  INFO - Role '$role' ja existe" -ForegroundColor DarkYellow
        } else {
            Write-Host "  ERRO ao criar role '$role': $_" -ForegroundColor Red
        }
    }
}

# 4. Criar Client logdash-webapp (mobile app — direct access grants + auth code)
Write-Host "`n[4/7] Criando client 'logdash-webapp' (mobile)..." -ForegroundColor Yellow
$mobileClientBody = @{
    clientId                  = "logdash-webapp"
    name                      = "LogDash Mobile App"
    description               = "Client para o app mobile Flutter"
    enabled                   = $true
    publicClient              = $true
    standardFlowEnabled       = $true
    directAccessGrantsEnabled = $true   # necessário para login com usuario/senha no app
    implicitFlowEnabled       = $false
    serviceAccountsEnabled    = $false
    redirectUris              = @(
        "logdash://callback",
        "http://localhost:8081/*",
        "http://10.0.2.2:8081/*"
    )
    webOrigins                = @("*")
    attributes                = @{
        "pkce.code.challenge.method" = "S256"
    }
} | ConvertTo-Json -Depth 5

try {
    Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/clients" -Method Post -Headers $headers -Body $mobileClientBody | Out-Null
    Write-Host "  OK - Client 'logdash-webapp' criado" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "  INFO - Client 'logdash-webapp' ja existe" -ForegroundColor DarkYellow
    } else {
        Write-Host "  ERRO: $_" -ForegroundColor Red
    }
}

# 5. Criar Client backoffice-webapp (Swagger UI — Authorization Code + PKCE)
Write-Host "`n[5/7] Criando client 'backoffice-webapp' (Swagger)..." -ForegroundColor Yellow
$swaggerClientBody = @{
    clientId                  = "backoffice-webapp"
    name                      = "Backoffice Webapp / Swagger"
    description               = "Client para o Swagger UI e frontend web admin"
    enabled                   = $true
    publicClient              = $true
    standardFlowEnabled       = $true
    directAccessGrantsEnabled = $true
    implicitFlowEnabled       = $false
    serviceAccountsEnabled    = $false
    redirectUris              = @(
        "http://localhost:8081/swagger-ui/oauth2-redirect.html",
        "http://localhost:8081/*",
        "http://localhost:3000/*"
    )
    webOrigins                = @("*")
    attributes                = @{
        "pkce.code.challenge.method" = "S256"
    }
} | ConvertTo-Json -Depth 5

try {
    Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/clients" -Method Post -Headers $headers -Body $swaggerClientBody | Out-Null
    Write-Host "  OK - Client 'backoffice-webapp' criado" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "  INFO - Client 'backoffice-webapp' ja existe" -ForegroundColor DarkYellow
    } else {
        Write-Host "  ERRO: $_" -ForegroundColor Red
    }
}

# 6. Criar usuarios de teste
Write-Host "`n[6/7] Criando usuarios de teste..." -ForegroundColor Yellow

$users = @(
    @{ username = "admin.user";      password = "admin123";      role = "ADMIN";      firstName = "Admin";      lastName = "LogDash" },
    @{ username = "operator.user";   password = "operator123";   role = "OPERATOR";   firstName = "Operator";   lastName = "LogDash" },
    @{ username = "dispatcher.user"; password = "dispatcher123"; role = "DISPATCHER"; firstName = "Dispatcher"; lastName = "LogDash" },
    @{ username = "client.user";     password = "client123";     role = "CLIENT";     firstName = "Cliente";    lastName = "Teste" },
    @{ username = "courier.user";    password = "courier123";    role = "COURIER";    firstName = "Entregador"; lastName = "Teste" }
)

foreach ($u in $users) {
    $userBody = @{
        username    = $u.username
        firstName   = $u.firstName
        lastName    = $u.lastName
        email       = "$($u.username)@logdash.com.br"
        enabled     = $true
        credentials = @(@{
            type      = "password"
            value     = $u.password
            temporary = $false
        })
    } | ConvertTo-Json -Depth 5

    try {
        Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/users" -Method Post -Headers $headers -Body $userBody | Out-Null
        Write-Host "  OK - Usuario '$($u.username)' criado" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            Write-Host "  INFO - Usuario '$($u.username)' ja existe" -ForegroundColor DarkYellow
        } else {
            Write-Host "  ERRO ao criar usuario '$($u.username)': $_" -ForegroundColor Red
            continue
        }
    }

    # Buscar ID do usuario
    $userId = (Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/users?username=$($u.username)" -Headers $headers)[0].id

    # Buscar role e atribuir
    $roleObj = Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/roles/$($u.role)" -Headers $headers
    $roleAssign = @($roleObj) | ConvertTo-Json -Depth 3

    Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/users/$userId/role-mappings/realm" `
        -Method Post -Headers $headers -Body $roleAssign | Out-Null
    Write-Host "  OK - Role '$($u.role)' atribuida a '$($u.username)'" -ForegroundColor Green
}

# 7. Resumo
Write-Host "`n[7/7] Configuracao concluida!" -ForegroundColor Cyan
Write-Host "`n=== RESUMO ===" -ForegroundColor Cyan
Write-Host "Realm    : $REALM"
Write-Host "Clients  : logdash-webapp (mobile) | backoffice-webapp (Swagger)"
Write-Host ""
Write-Host "Usuarios criados:" -ForegroundColor White
Write-Host "  admin.user       / admin123       -> role: ADMIN"
Write-Host "  operator.user    / operator123    -> role: OPERATOR"
Write-Host "  dispatcher.user  / dispatcher123  -> role: DISPATCHER"
Write-Host "  client.user      / client123      -> role: CLIENT"
Write-Host "  courier.user     / courier123     -> role: COURIER"
Write-Host ""
Write-Host "AVISO: apos criar um entregador no sistema, copie o Keycloak ID" -ForegroundColor Yellow
Write-Host "       (sub do JWT) e preencha no campo keycloakId do courier." -ForegroundColor Yellow
Write-Host "       OU use o endpoint POST /api/couriers/me para auto-cadastro." -ForegroundColor Yellow
Write-Host ""
Write-Host "Admin Console : $KC_URL/admin" -ForegroundColor Cyan
Write-Host "Swagger UI    : http://localhost:8081/swagger-ui.html" -ForegroundColor Cyan
Write-Host "App Mobile    : login com client.user ou courier.user" -ForegroundColor Cyan
Write-Host ""
Write-Host "No Swagger, clique em 'Authorize' e use um dos usuarios acima." -ForegroundColor Yellow
