# Manual Maestro y Corporativo de CI/CD: Automatización y Despliegue de Monolito4toA

Este manual técnico proporciona la documentación exhaustiva para la instalación, configuración, aseguramiento y despliegue del entorno de Integración Continua (CI) y Despliegue Continuo (CD) del proyecto **Monolito4toA**.

---

## 1. Arquitectura General del Pipeline de CI/CD

El flujo de control se diseña bajo un esquema híbrido: el servidor de coordinación de Jenkins se ejecuta de forma aislada dentro de un contenedor Linux (Docker), mientras que las tareas de restauración, compilación, empaquetado y copia física se delegan a un agente nativo de Windows (el Host físico) debido a la dependencia tecnológica de .NET Framework 4.8.1.

![Arquitectura del Pipeline de CI/CD](C:\Users\jmfr1\.gemini\antigravity\brain\d96b9ac7-a9a1-45d3-9a5d-08d3b1c3199f\cicd_pipeline_architecture_1782220633060.png)

---

## 2. Fase 1: Habilitación de Entornos y Requisitos del Host (Paso a Paso)

### A. Activación del Servidor de Internet Information Services (IIS) en Windows
Dado que la aplicación web es de tecnología ASP.NET clásica, se requiere activar el rol de servidor IIS en Windows:
1. Presiona `Win + R`, escribe `optionalfeatures` y presiona Enter.
2. En la ventana de características de Windows, despliega **Internet Information Services**.
3. Asegúrate de marcar los siguientes componentes específicos:
   * **Herramientas de administración web**: Consola de administración de IIS.
   * **Servicios de World Wide Web** ➔ **Características de desarrollo de aplicaciones**:
     * `.NET Extensibility 4.8` (o superior)
     * `ASP.NET 4.8` (o superior)
     * `Extensiones ISAPI`
     * `Filtros ISAPI`
4. Clic en **Aceptar** y espera a que Windows instale los componentes. Reinicia la computadora si se solicita.

### B. Habilitación del Protocolo TCP/IP en SQL Server (SQLEXPRESS)
Para permitir que la aplicación desplegada se conecte correctamente a las bases de datos de SQL Server local, el motor de base de datos debe escuchar peticiones a través del protocolo TCP/IP:
1. Abre el menú inicio y busca **SQL Server Configuration Manager** (Administrador de configuración de SQL Server).
2. Despliega **SQL Server Network Configuration** (Configuración de red de SQL Server) ➔ **Protocols for SQLEXPRESS** (Protocolos de SQLEXPRESS).
3. Haz clic derecho sobre **TCP/IP** y selecciona **Enable** (Habilitar).
4. Ve a **SQL Server Services**, haz clic derecho sobre el servicio **SQL Server (SQLEXPRESS)** y selecciona **Restart** (Reiniciar).

### C. Descarga e Instalación de Docker Desktop
1. Descarga el instalador oficial desde [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Ejecuta el archivo e instala manteniendo la opción **"Use WSL 2 instead of Hyper-V"** marcada.
3. Tras la instalación y el reinicio del sistema, abre Docker Desktop para iniciar la máquina virtual interna de Linux.

### D. Descarga e Instalación de Java Development Kit (JDK 17)
1. Descarga JDK 17 desde [Adoptium Temurin](https://adoptium.net/).
2. Sigue el instalador y habilita la configuración de la variable `JAVA_HOME`.
3. Valida la instalación ejecutando en PowerShell:
   ```powershell
   java -version
   ```

### E. Descarga e Instalación de Node.js y npm
1. Descarga el instalador LTS desde [Node.js](https://nodejs.org/).
2. Realiza la instalación por defecto.
3. Valida ejecutando en PowerShell:
   ```powershell
   node -v
   npm -v
   ```

---

## 3. Fase 2: Configuración del Proyecto y Control de Versiones (Git)

### A. El archivo de exclusión `.gitignore`
* **Ruta**: `c:\Users\jmfr1\source\repos\Monolito4toA\.gitignore`
* **Código Completo**:
```text
## Visual Studio / MSBuild
[Db]in/
[Oo]bj/
[Pp]ackages/
.vs/
*.user
*.suo
*.userosscache
*.sln.docstates
*.userpref
*.dbmdl
*.jfm

## Node / Frontend
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

## Backups and Archives (Important to avoid uploading large database backups)
*.bak
*.zip
*.rar
*.7z
Monolillo4to_Backup.bak
Monolillo4to_Backup.zip
Proyecto_Para_Subir.zip

## Local configuration files and history
Web_temp*.config
*.log
prompts_historial_monolito.txt
secrets.config
```

### B. El archivo de credenciales externas `secrets.config`
Para evitar alertas de seguridad en GitHub, aislamos los secretos locales en este archivo externo.
* **Ruta**: `c:\Users\jmfr1\source\repos\Monolito4toA\Monolito4toA\secrets.config`
* **Código Completo**:
```xml
<appSettings>
  <!-- Credenciales externas excluidas de Git -->
  <add key="FacebookAppId" value="TU_FACEBOOK_APP_ID_AQUÍ" />
  <add key="FacebookAppSecret" value="TU_FACEBOOK_APP_SECRET_AQUÍ" />
  <add key="GoogleClientId" value="TU_GOOGLE_CLIENT_ID_AQUÍ" />
  <add key="GoogleClientSecret" value="TU_GOOGLE_CLIENT_SECRET_AQUÍ" />
</appSettings>
```

### C. Comandos de Consola de Inicialización Git (PowerShell)
```powershell
# 1. Moverse a la carpeta del código fuente
cd c:\Users\jmfr1\source\repos\Monolito4toA

# 2. Inicializar base de datos de control de versiones de Git
git init
# (Crea la estructura de carpetas oculta .git para almacenar el historial)

# 3. Vincular el repositorio local con el repositorio en la nube de GitHub
git remote add origin https://github.com/fjose148/Monolito4toA.git
# (Define 'origin' como el alias del servidor remoto para las subidas)

# 4. Agregar todos los archivos al índice para el commit (excluyendo lo declarado en .gitignore)
git add .

# 5. Registrar los cambios agregados en el historial local
git commit -m "Estructuración y blindaje inicial de CI/CD"
# (-m define la etiqueta o mensaje descriptivo de esta versión)

# 6. Definir la rama principal con el nombre estandarizado 'main'
git branch -M main

# 7. Subir el código por primera vez y vincular la rama upstream
git push -u origin main
# (-u asocia de forma permanente la rama local con la remota en GitHub)
```

---

## 4. Fase 3: Infraestructura de Jenkins Master en Docker

### A. Archivo de Orquestación `docker-compose.yml`
* **Ruta**: `c:\Users\jmfr1\source\repos\Monolito4toA\docker-compose.yml`
* **Código Completo**:
```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins_master
    restart: always
    ports:
      - "8080:8080"   # Puerto de acceso al portal web de administración de Jenkins
      - "50000:50000" # Puerto de comunicación TCP interno para el agente de compilación
    volumes:
      - jenkins_data:/var/jenkins_home # Volumen persistente para datos de Jenkins
    environment:
      - TZ=America/Guayaquil

volumes:
  jenkins_data:
    name: monolito4toa_jenkins_data
```

### B. Comandos en PowerShell para desplegar el servidor:
```powershell
# 1. Construir y levantar el contenedor en segundo plano (detached mode)
docker-compose up -d
# (El parámetro -d libera la terminal inmediatamente)

# 2. Extraer la contraseña temporal para el primer inicio de sesión
docker exec jenkins_master cat /var/jenkins_home/secrets/initialAdminPassword
# (docker exec corre un comando dentro del contenedor activo 'jenkins_master')
```

---

## 5. Fase 4: Registro y Conexión del Agente de Windows

Dado que las soluciones web de .NET Framework clásico requieren del compilador propietario de Windows (MSBuild.exe), el servidor Jenkins Master delegará las compilaciones al sistema físico local (Host) mediante un canal WebSocket.

### A. Alta del Nodo en el Portal Web de Jenkins
1. Ingresa a `http://localhost:8080` con tu cuenta de administrador.
2. Navega a **Manage Jenkins** ➔ **Nodes** ➔ **New Node**.
3. Configura los siguientes campos:
   * **Node name**: `windows-agent`
   * **Type**: `Permanent Agent` ➔ Clic en **Create**.
   * **Description**: Nodo compilador para la plataforma de .NET Windows.
   * **Number of executors**: `2` (cantidad de compilaciones concurrentes permitidas).
   * **Remote root directory**: `C:\jenkins` (Ruta física de trabajo en el host).
   * **Labels**: `windows` (Etiqueta de enlace para el pipeline).
   * **Launch method**: Selecciona **`Launch agent by connecting it to the controller`**.
   * **Use WebSocket**: Marca esta casilla (Permite la comunicación TCP sobre HTTP evitando configurar firewalls).
4. Haz clic en **Save** (Guardar).

### B. Comando de PowerShell (Ejecutado como ADMINISTRADOR) para Inicializar Conexión
```powershell
# 1. Crear el directorio físico del Agente en el disco local
mkdir C:\jenkins -Force
# (-Force evita la interrupción si la carpeta ya existía)

# 2. Navegar a la carpeta creada
cd C:\jenkins

# 3. Descargar el cliente agente de Java de forma directa
Invoke-WebRequest -Uri "http://localhost:8080/jnlpJars/agent.jar" -OutFile "agent.jar"
# (Invoke-WebRequest realiza una petición HTTP GET para obtener el archivo compilado)

# 4. Iniciar el agente y establecer el canal de WebSocket activo
java -jar agent.jar -url http://localhost:8080/ -secret 216a73ea68542a4d6cbaaa28ad50e177fd445ec11d7730ab9b445fcb05b8f480 -name "windows-agent" -webSocket -workDir "C:\jenkins"
# (Este proceso de Java debe permanecer abierto de fondo para recibir comandos de compilación)
```

---

## 6. Fase 5: Estructuración y Lógica del Pipeline (`Jenkinsfile`)

El pipeline se encuentra configurado como código de orquestación declarativo, garantizando la repetibilidad del proceso de compilación y despliegue.

* **Ruta**: `c:\Users\jmfr1\source\repos\Monolito4toA\Jenkinsfile`
* **Código Completo**:
```groovy
pipeline {
    // Restringe la ejecución de todo este pipeline exclusivamente al agente etiquetado como 'windows'
    agent { label 'windows' } 

    environment {
        // Rutas físicas y variables del entorno del Agente Windows
        MSBUILD_PATH = 'C:\\Program Files\\Microsoft Visual Studio\\18\\Community\\MSBuild\\Current\\Bin\\MSBuild.exe'
        SOLUTION_NAME = 'Monolito4toA.slnx'
        PROJECT_PATH = 'Monolito4toA\\Monolito4toA.csproj'
        IIS_PUBLISH_DIR = 'C:\\inetpub\\wwwroot\\Monolito4toA'
    }

    stages {
        // ---------------------------------------------------------
        // ETAPA 1: Restaurar Paquetes NuGet (.NET)
        // ---------------------------------------------------------
        stage('Restaurar Paquetes NuGet') {
            steps {
                powershell '''
                Write-Host "Iniciando restauración de paquetes NuGet..."
                
                # Descarga nuget.exe si no se encuentra presente en la raíz
                if (-not (Test-Path "nuget.exe")) {
                    Write-Host "nuget.exe no encontrado. Descargando..."
                    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
                }

                # Ejecuta la restauración de las librerías definidas en los proyectos
                .\\nuget.exe restore $env:SOLUTION_NAME
                Write-Host "Restauración de paquetes NuGet completada con éxito."
                '''
            }
        }

        // ---------------------------------------------------------
        // ETAPA 2: Restaurar Dependencias de Interfaz Frontend (NPM)
        // ---------------------------------------------------------
        stage('Restaurar Paquetes npm') {
            steps {
                powershell '''
                Write-Host "Instalando paquetes npm (Frontend)..."
                
                # Moverse al directorio del proyecto que contiene package.json
                cd Monolito4toA
                
                # Instalar dependencias web de forma silenciosa
                npm install --no-audit --no-fund
                Write-Host "Instalación de paquetes de frontend completada."
                '''
            }
        }

        // ---------------------------------------------------------
        // ETAPA 3: Compilación del Proyecto
        // ---------------------------------------------------------
        stage('Compilar Solución') {
            steps {
                powershell '''
                Write-Host "Iniciando compilación del código fuente en configuración Release..."
                
                # Compilar la solución usando el MSBuild del sistema
                & "$env:MSBUILD_PATH" $env:SOLUTION_NAME /p:Configuration=Release /p:Platform="Any CPU"
                Write-Host "Compilación finalizada exitosamente."
                '''
            }
        }

        // ---------------------------------------------------------
        // ETAPA 4: Publicación Web y Generación de Artefactos
        // ---------------------------------------------------------
        stage('Publicar Aplicación') {
            steps {
                powershell '''
                Write-Host "Generando archivos y assets listos para distribución..."
                
                # Compilar y empaquetar el proyecto específico con salida a un directorio temporal
                & "$env:MSBUILD_PATH" $env:PROJECT_PATH /p:Configuration=Release /p:DeployOnBuild=true /p:PublishUrl="$env:WORKSPACE\\publish_output" /p:DeployTarget=WebPublish /p:WebPublishMethod=FileSystem
                Write-Host "Artefactos listos en $env:WORKSPACE\\publish_output"
                '''
            }
        }

        // ---------------------------------------------------------
        // ETAPA 5: Despliegue Físico en el Directorio del Servidor Web IIS
        // ---------------------------------------------------------
        stage('Desplegar en IIS') {
            steps {
                powershell '''
                Write-Host "Desplegando en IIS ($env:IIS_PUBLISH_DIR)..."
                
                # Crear la carpeta de despliegue si no existe
                if (-not (Test-Path $env:IIS_PUBLISH_DIR)) {
                    New-Item -Path $env:IIS_PUBLISH_DIR -ItemType Directory -Force
                }
                
                # Copiar los artefactos limpios de forma recursiva y forzada
                Copy-Item -Path "$env:WORKSPACE\\publish_output\\*" -Destination $env:IIS_PUBLISH_DIR -Recurse -Force
                Write-Host "Despliegue en IIS completado con éxito."
                '''
            }
        }
    }
}
```

---

## 7. Fase 6: Configuración de IIS y Permisos del Directorio

Para evitar errores de denegación de permisos (`UnauthorizedAccessException`) durante la copia física de archivos por parte del agente de Jenkins, se debe establecer control total en el directorio web.

### A. Comandos de Asignación de Permisos (PowerShell como Administrador):
```powershell
# 1. Crear físicamente la carpeta del sitio
New-Item -Path "C:\inetpub\wwwroot\Monolito4toA" -ItemType Directory -Force

# 2. Otorgar permisos heredables de control total al usuario jmfr1 (que ejecuta el agente de Jenkins)
icacls "C:\inetpub\wwwroot\Monolito4toA" /grant "kyomu\jmfr1:(OI)(CI)F" /T
# Explicación técnica de modificadores de icacls:
# /grant : Concede permisos de acceso.
# (OI)   : Object Inherit. Hereda los permisos a los archivos nuevos que se agreguen.
# (CI)   : Container Inherit. Hereda los permisos a los directorios y subcarpetas que se agreguen.
# F      : Full Control. Otorga control total de lectura, escritura y modificación de permisos.
# /T     : Operación recursiva sobre toda la estructura actual.
```

---

## 8. Fase 7: Script de Pruebas Manuales (`run_tests_manual.ps1`)

Este script permite ejecutar localmente todas las etapas de validación de manera síncrona. Sirve para descartar fallos de red, compilación o base de datos de manera aislada de Jenkins.

* **Ruta**: `c:\Users\jmfr1\source\repos\Monolito4toA\run_tests_manual.ps1`
* **Código Completo**:
```powershell
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

# Configuración de Base de Datos SQL Server Local
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
```

---

## 9. Fase 9: Guía Rápida de Comandos Docker en PowerShell

* **`docker ps`**
  * *¿Para qué sirve?*: Lista los contenedores encendidos en el sistema.
* **`docker ps -a`**
  * *¿Para qué sirve?*: Lista todos los contenedores existentes (encendidos y apagados).
* **`docker logs -f jenkins_master`**
  * *¿Para qué sirve?*: Sigue en tiempo real los registros del servidor Jenkins para diagnosticar fallos.
* **`docker stop jenkins_master`**
  * *¿Para qué sirve?*: Detiene de forma controlada el contenedor de Jenkins sin borrar datos.
* **`docker start jenkins_master`**
  * *¿Para qué sirve?*: Inicia el contenedor de Jenkins previamente creado o detenido.
* **`docker exec -it jenkins_master bash`**
  * *¿Para qué sirve?*: Entra a la consola interactiva (Linux shell) del contenedor de Jenkins. Escribe `exit` para salir.
* **`docker volume rm monolito4toa_jenkins_data`**
  * *¿Para qué sirve?*: Borra permanentemente el almacenamiento del contenedor (pipelines, credenciales, usuarios de Jenkins).
