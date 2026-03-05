# ============================================================
# Script para configurar o Keycloak automaticamente
# Realm: delivery-backoffice
# Client: backoffice-webapp (public, Authorization Code + PKCE)
# Usuarios: admin / operator / dispatcher
# ============================================================
# Uso: .\setup-keycloak.ps1
# ============================================================

$KC_URL      = "http://localhost:8080"
$ADMIN_USER  = "admin"
$ADMIN_PASS  = "admin"
$REALM       = "delivery-backoffice"
$CLIENT_ID   = "backoffice-webapp"

Write-Host "=== Configurando Keycloak ===" -ForegroundColor Cyan

# 1. Obter token de admin do realm master
Write-Host "`n[1/6] Autenticando no realm master..." -ForegroundColor Yellow
$tokenResponse = Invoke-RestMethod `
    -Uri "$KC_URL/realms/master/protocol/openid-connect/token" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body "grant_type=password&client_id=admin-cli&username=$ADMIN_USER&password=$ADMIN_PASS"

$token = $tokenResponse.access_token
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
Write-Host "  OK - Token obtido" -ForegroundColor Green

# 2. Criar Realm
Write-Host "`n[2/6] Criando realm '$REALM'..." -ForegroundColor Yellow
$realmBody = @{
    realm       = $REALM
    displayName = "Delivery Backoffice"
    enabled     = $true
    loginTheme  = "keycloak"
    accessTokenLifespan = 300
    ssoSessionMaxLifespan = 36000
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
Write-Host "`n[3/6] Criando roles (ADMIN, OPERATOR, DISPATCHER)..." -ForegroundColor Yellow
foreach ($role in @("ADMIN", "OPERATOR", "DISPATCHER")) {
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

# 4. Criar Client (backoffice-webapp) — public, Authorization Code + PKCE
Write-Host "`n[4/6] Criando client '$CLIENT_ID'..." -ForegroundColor Yellow
$clientBody = @{
    clientId                     = $CLIENT_ID
    name                         = "Backoffice Webapp"
    description                  = "Cliente para o Swagger UI e frontend"
    enabled                      = $true
    publicClient                 = $true
    standardFlowEnabled          = $true
    directAccessGrantsEnabled    = $true
    implicitFlowEnabled          = $false
    serviceAccountsEnabled       = $false
    redirectUris                 = @(
        "http://localhost:8081/swagger-ui/oauth2-redirect.html",
        "http://localhost:8081/*",
        "http://localhost:3000/*"
    )
    webOrigins                   = @("*")
    attributes                   = @{
        "pkce.code.challenge.method" = "S256"
    }
} | ConvertTo-Json -Depth 5

try {
    Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/clients" -Method Post -Headers $headers -Body $clientBody | Out-Null
    Write-Host "  OK - Client criado" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "  INFO - Client ja existe" -ForegroundColor DarkYellow
    } else {
        Write-Host "  ERRO: $_" -ForegroundColor Red; exit 1
    }
}

# 5. Criar usuarios de teste
Write-Host "`n[5/6] Criando usuarios de teste..." -ForegroundColor Yellow

$users = @(
    @{ username = "admin.user"; password = "admin123"; role = "ADMIN"; firstName = "Admin"; lastName = "User" },
    @{ username = "operator.user"; password = "operator123"; role = "OPERATOR"; firstName = "Operator"; lastName = "User" },
    @{ username = "dispatcher.user"; password = "dispatcher123"; role = "DISPATCHER"; firstName = "Dispatcher"; lastName = "User" }
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

    Invoke-RestMethod -Uri "$KC_URL/admin/realms/$REALM/users/$userId/role-mappings/realm" -Method Post -Headers $headers -Body $roleAssign | Out-Null
    Write-Host "  OK - Role '$($u.role)' atribuida a '$($u.username)'" -ForegroundColor Green
}

# 6. Resumo
Write-Host "`n[6/6] Configuracao concluida!" -ForegroundColor Cyan
Write-Host "`n=== RESUMO ===" -ForegroundColor Cyan
Write-Host "Realm    : $REALM"
Write-Host "Client   : $CLIENT_ID (public)"
Write-Host ""
Write-Host "Usuarios criados:"
Write-Host "  admin.user      / admin123      -> role: ADMIN"
Write-Host "  operator.user   / operator123   -> role: OPERATOR"
Write-Host "  dispatcher.user / dispatcher123 -> role: DISPATCHER"
Write-Host ""
Write-Host "Admin Console: $KC_URL/admin" -ForegroundColor Cyan
Write-Host "Swagger UI   : http://localhost:8081/swagger-ui.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "No Swagger, clique em 'Authorize' e use um dos usuarios acima." -ForegroundColor Yellow
