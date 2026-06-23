# Script para ejecutar pruebas manuales de compilación, estructura y conectividad
# Ejecutar en PowerShell como Administrador

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "      INICIANDO PRUEBAS DEL SISTEMA (Monolito4toA)        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$MSBUILD = "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe"
$NUGET = "C:\Users\jmfr1\source\repos\Monolito4toA\nuget.exe"
$SOLUTION = "C:\Users\jmfr1\source\repos\Monolito4toA\Monolito4toA.slnx"
$PROJECT = "C:\Users\jmfr1\source\repos\Monolito4toA\Monolito4toA\Monolito4toA.csproj"
$TEMP_PUBLISH = "C:\Users\jmfr1\source\repos\Monolito4toA\publish_test"

# Configuración de Base de Datos
$DB_SERVER = "KYOMU\SQLEXPRESS"
$DB_NAME = "Monolillo4to"
$DB_USER = "4toA"
$DB_PASS = "family"

# ---------------------------------------------------------
# ETAPA 1: Restauración de NuGet
# ---------------------------------------------------------
Write-Host "`n[1/5] Restaurando paquetes NuGet..." -ForegroundColor Yellow
if (-not (Test-Path $NUGET)) {
    Write-Host "   => Descargando nuget.exe..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $NUGET | Out-Null
}

if (Test-Path $NUGET) {
    & $NUGET restore $SOLUTION | Out-Null
    Write-Host "   => [OK] Paquetes NuGet restaurados con éxito." -ForegroundColor Green
} else {
    Write-Host "   => [ERROR] No se pudo obtener nuget.exe." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# ETAPA 2: Restauración de dependencias NPM
# ---------------------------------------------------------
Write-Host "`n[2/5] Restaurando dependencias NPM (node_modules)..." -ForegroundColor Yellow
$projectDir = Split-Path $PROJECT
Push-Location $projectDir
try {
    & npm install --no-audit --no-fund
    Write-Host "   => [OK] Dependencias NPM restauradas con éxito." -ForegroundColor Green
} catch {
    Write-Host "   => [ERROR] Error durante npm install." -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

# ---------------------------------------------------------
# ETAPA 3: Compilación y Generación de Publicación de Prueba
# ---------------------------------------------------------
Write-Host "`n[3/5] Compilando el proyecto web con MSBuild..." -ForegroundColor Yellow
if (Test-Path $MSBUILD) {
    # Eliminar publicación previa de prueba si existe
    if (Test-Path $TEMP_PUBLISH) { Remove-Item $TEMP_PUBLISH -Recurse -Force | Out-Null }
    
    # Ejecutar compilación y empaquetamiento a carpeta de prueba
    Write-Host "   => Ejecutando compilación..." -ForegroundColor Gray
    $buildOutput = & $MSBUILD $PROJECT /p:Configuration=Release /p:DeployOnBuild=true /p:PublishUrl="$TEMP_PUBLISH" /p:DeployTarget=WebPublish /p:WebPublishMethod=FileSystem 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   => [OK] Compilación exitosa sin errores." -ForegroundColor Green
    } else {
        Write-Host "   => [ERROR] La compilación falló." -ForegroundColor Red
        Write-Host $buildOutput -ForegroundColor DarkRed
        exit 1
    }
} else {
    Write-Host "   => [ERROR] No se encontró MSBuild.exe en: $MSBUILD" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# ETAPA 4: Verificación de Estructura y Archivos de Publicación
# ---------------------------------------------------------
Write-Host "`n[4/5] Verificando archivos de publicación generados..." -ForegroundColor Yellow
$errors = 0

if (Test-Path "$TEMP_PUBLISH\Web.config") {
    Write-Host "   => [OK] Web.config generado correctamente." -ForegroundColor Green
} else {
    Write-Host "   => [FALLIDO] No se generó el archivo Web.config." -ForegroundColor Red
    $errors++
}

if (Test-Path "$TEMP_PUBLISH\Seguridad\Login.aspx") {
    Write-Host "   => [OK] Seguridad\Login.aspx (Página predeterminada) generada correctamente." -ForegroundColor Green
} else {
    Write-Host "   => [FALLIDO] No se generó el archivo Seguridad\Login.aspx." -ForegroundColor Red
    $errors++
}

if (Test-Path "$TEMP_PUBLISH\bin\Monolito4toA.dll") {
    Write-Host "   => [OK] Binarios compilados (Monolito4toA.dll) generados correctamente." -ForegroundColor Green
} else {
    Write-Host "   => [FALLIDO] No se generó la librería Monolito4toA.dll." -ForegroundColor Red
    $errors++
}

if ($errors -eq 0) {
    Write-Host "   => [OK] Validación de estructura exitosa." -ForegroundColor Green
} else {
    Write-Host "   => [ERROR] Estructura de despliegue inválida." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# ETAPA 5: Conexión a Base de Datos SQL Server
# ---------------------------------------------------------
Write-Host "`n[5/5] Verificando conexión a la Base de Datos SQL Server..." -ForegroundColor Yellow
try {
    $connectionString = "Server=$DB_SERVER;Database=$DB_NAME;User ID=$DB_USER;Password=$DB_PASS;Encrypt=False;TrustServerCertificate=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # Ejecutar una consulta simple para validar
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT COUNT(*) FROM tbl_usuario"
    $count = $command.ExecuteScalar()
    
    Write-Host "   => [OK] Conectado exitosamente al servidor: $DB_SERVER" -ForegroundColor Green
    Write-Host "   => [OK] Base de datos activa ($DB_NAME). Total de usuarios registrados: $count" -ForegroundColor Green
    
    $connection.Close()
} catch {
    Write-Host "   => [ERROR] Falló la conexión a la base de datos SQL Server." -ForegroundColor Red
    Write-Host "      Detalle: $_" -ForegroundColor DarkRed
    exit 1
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "        TODAS LAS PRUEBAS SE PASARON EXITOSAMENTE          " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
