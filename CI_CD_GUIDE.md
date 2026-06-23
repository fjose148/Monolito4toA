# Guía Visual y Cronológica del Pipeline de CI/CD (Monolito4toA)

Este documento detalla, de forma visual y con instrucciones paso a paso, cómo se configuró e implementó toda la infraestructura de integración continua y despliegue del proyecto `Monolito4toA`.

---

## 1. Arquitectura General del Sistema
El siguiente diagrama ilustra cómo fluyen los datos y comandos a través del sistema:

![Arquitectura del Pipeline de CI/CD](C:\Users\jmfr1\.gemini\antigravity\brain\d96b9ac7-a9a1-45d3-9a5d-08d3b1c3199f\cicd_pipeline_architecture_1782220633060.png)

---

## 2. Bitácora de Pasos Cronológicos (Fácil de Entender)

### 📌 PASO 1: Preparar tu Repositorio de Git
1. Abrir la terminal **PowerShell** en tu computadora.
2. Navegar hasta la carpeta del proyecto:
   ```powershell
   cd c:\Users\jmfr1\source\repos\Monolito4toA
   ```
3. Inicializar y subir el código limpio a GitHub:
   ```powershell
   git init
   git remote add origin https://github.com/fjose148/Monolito4toA.git
   git add .
   git commit -m "Inicialización del repositorio"
   git push -u origin main
   ```

### 📌 PASO 2: Levantar Jenkins en Docker
1. En la misma carpeta de tu proyecto (donde se encuentra `docker-compose.yml`), levanta el servidor web de Jenkins:
   ```powershell
   docker-compose up -d
   ```
2. Obtener la contraseña inicial para desbloquear el panel web:
   ```powershell
   docker exec jenkins_master cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Abrir en tu navegador: **`http://localhost:8080`**
4. Pegar la contraseña, seleccionar **"Install suggested plugins"** y crear tu usuario administrador (ej. `admin`).

### 📌 PASO 3: Conectar el Agente de Windows
Como MSBuild solo funciona en Windows, debemos conectar tu sistema host como agente compilador.

1. **En la Web de Jenkins**:
   * Ir a **Administrar Jenkins** (`Manage Jenkins`) ➔ **Nodos** (`Nodes`) ➔ **Nuevo Nodo** (`New Node`).
   * Nombre: `windows-agent` | Tipo: `Permanent Agent`.
   * Directorio raíz remoto: `C:\jenkins`
   * Etiqueta (Labels): `windows` *(obligatorio)*.
   * Método de lanzamiento: **`Launch agent by connecting it to the controller`** (el segundo de la lista desplegable).
   * Clic en **Guardar**.
2. **En tu Consola de Windows (Abrir PowerShell como ADMINISTRADOR)**:
   ```powershell
   # Crear la carpeta de trabajo
   mkdir C:\jenkins -Force
   cd C:\jenkins

   # Descargar el conector agent.jar
   Invoke-WebRequest -Uri "http://localhost:8080/jnlpJars/agent.jar" -OutFile "agent.jar"

   # Conectar el agente (dejar esta consola abierta)
   java -jar agent.jar -url http://localhost:8080/ -secret 216a73ea68542a4d6cbaaa28ad50e177fd445ec11d7730ab9b445fcb05b8f480 -name "windows-agent" -webSocket -workDir "C:\jenkins"
   ```

### 📌 PASO 4: Configurar los Permisos en IIS (Servidor Web)
Para que Jenkins pueda copiar los archivos compilados en la carpeta protegida de IIS local:
1. En tu consola de **Administrador**, ejecutar:
   ```powershell
   # Crear la carpeta física del sitio en IIS
   New-Item -Path "C:\inetpub\wwwroot\Monolito4toA" -ItemType Directory -Force

   # Darle control total a tu usuario sobre esa carpeta
   icacls "C:\inetpub\wwwroot\Monolito4toA" /grant "kyomu\jmfr1:(OI)(CI)F" /T
   ```

### 📌 PASO 5: Crear el Pipeline de Despliegue en la Web
1. En la página de inicio de Jenkins (`http://localhost:8080`), clic en **Nueva Tarea** (`New Item`).
2. Nombre: `Monolito4toA-Pipeline` | Tipo: **Pipeline** (Proyecto de tubería) ➔ Clic en **Aceptar**.
3. En la sección **Pipeline**:
   * **Definition**: Seleccionar `Pipeline script from SCM`.
   * **SCM**: Seleccionar `Git`.
   * **Repository URL**: Tu repositorio de GitHub (`https://github.com/fjose148/Monolito4toA.git`).
   * **Branch Specifier**: Cambiar a `*/main`.
   * **Script Path**: Escribir `Jenkinsfile`.
4. Clic en **Guardar**.
5. Clic en **Construir Ahora** (*Build Now*) para arrancar el despliegue automático.

---

## 3. Guía de Comandos Rápidos Docker (PowerShell)

| Acción | Comando en PowerShell |
| :--- | :--- |
| **Encender Jenkins** | `docker-compose up -d` |
| **Apagar Jenkins** | `docker-compose down` |
| **Ver estado de contenedores** | `docker ps -a` |
| **Ver logs del servidor** | `docker logs -f jenkins_master` |
| **Consola interna de Jenkins** | `docker exec -it jenkins_master bash` |
| **Limpieza de base de datos Docker** | `docker volume rm monolito4toa_jenkins_data` |

---

## 4. Script de Validación Manual (`run_tests_manual.ps1`)
Para probar la compilación y conectividad a SQL Server (`KYOMU\SQLEXPRESS`) sin pasar por Jenkins, ejecuta este script en tu carpeta raíz:
```powershell
# 1. Entrar a la carpeta del proyecto
cd c:\Users\jmfr1\source\repos\Monolito4toA

# 2. Ejecutar el validador
.\run_tests_manual.ps1
```
