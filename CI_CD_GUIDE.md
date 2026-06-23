# Guía Completa de Configuración de CI/CD (Monolito4toA)

Esta guía documenta paso a paso toda la infraestructura y configuración creada para el proyecto **Monolito4toA**, desde la subida a Git hasta la automatización con Jenkins en Docker y el despliegue automático en el IIS local.

---

## 1. Requisitos Previos e Instalaciones
Para que todo este ecosistema funcione, se requiere tener instalado en el Host Windows:
* **Docker Desktop**: Para ejecutar el Jenkins Master en un contenedor.
* **Java (JDK o JRE 11/17)**: Necesario para ejecutar el agente local de Jenkins.
* **Node.js y npm**: Para restaurar las dependencias de frontend de la aplicación web.
* **MSBuild (Visual Studio 2022 / Build Tools)**: Para compilar aplicaciones de .NET Framework 4.8.1.
* **SQL Server (SQLEXPRESS) y MongoDB**: Instalados localmente para las bases de datos.

---

## 2. Paso 1: Configuración de Git y Seguridad
Para evitar subir secretos y archivos pesados innecesarios a GitHub, se realizaron las siguientes configuraciones:

### A. Limpieza de Secretos (OAuth)
Se extrajeron las credenciales del archivo `Web.config` y se guardaron en un archivo externo llamado `secrets.config` que **no se sube al repositorio**.
* **Archivo creado:** [secrets.config](file:///c:/Users/jmfr1/source/repos/Monolito4toA/Monolito4toA/secrets.config)
* **Modificación en Web.config:** Se configuró para leer las credenciales desde `secrets.config` apuntando a dicho archivo externo de configuración.

### B. Creación del `.gitignore`
Se creó el archivo `.gitignore` para omitir archivos compilados, temporales de Visual Studio, copias de seguridad de bases de datos y la carpeta `node_modules`.
* **Archivo creado:** [.gitignore](file:///c:/Users/jmfr1/source/repos/Monolito4toA/.gitignore)

### C. Comandos de Consola para Git (PowerShell)
Comandos para inicializar, añadir y subir el código al repositorio remoto:
```powershell
# 1. Inicializar Git (si no está inicializado)
git init

# 2. Agregar el repositorio remoto
git remote add origin https://github.com/fjose148/Monolito4toA.git

# 3. Guardar cambios localmente
git add .
git commit -m "Initial commit - Jenkins setup"

# 4. Cambiar a la rama principal y subir el código
git branch -M main
git push -u origin main
```

---

## 3. Paso 2: Jenkins Master en Docker
El servidor central de Jenkins corre en un contenedor Linux ligero a través de Docker.

### A. Archivo `docker-compose.yml`
* **Ruta:** [docker-compose.yml](file:///c:/Users/jmfr1/source/repos/Monolito4toA/docker-compose.yml)
Define el puerto `8080` para la web y el `50000` para la conexión de agentes de construcción.

### B. Comandos para arrancar Jenkins:
```powershell
# Levantar Jenkins en segundo plano (run from root folder)
docker-compose up -d

# Obtener la contraseña inicial de Administrador (para el primer inicio)
docker exec jenkins_master cat /var/jenkins_home/secrets/initialAdminPassword
```
*Una vez obtenido el código, se accede a `http://localhost:8080` y se instalan los plugins sugeridos.*

---

## 4. Paso 3: Conexión del Agente Windows
Dado que .NET Framework requiere compilarse bajo Windows (MSBuild), delegamos el trabajo de compilación al host Windows local configurándolo como Agente.

### A. Creación del nodo en la interfaz web de Jenkins:
1. Ir a **Administrar Jenkins** ➔ **Nodes** ➔ **Nuevo Nodo**.
2. Nombre: `windows-agent` | Tipo: Permanent Agent.
3. Directorio raíz remoto: `C:\jenkins`.
4. Etiqueta (Labels): `windows` *(fundamental para que el Jenkinsfile lo asigne)*.
5. Método de lanzamiento: `Launch agent by connecting it to the controller`.
6. Guardar.

### B. Comandos en PowerShell (como Administrador) para iniciar el Agente:
```powershell
# 1. Crear carpeta del agente y entrar a ella
mkdir C:\jenkins -Force
cd C:\jenkins

# 2. Descargar el archivo conector agent.jar
Invoke-WebRequest -Uri "http://localhost:8080/jnlpJars/agent.jar" -OutFile "agent.jar"

# 3. Conectar el agente a Jenkins (deja esta ventana de consola abierta)
java -jar agent.jar -url http://localhost:8080/ -secret 216a73ea68542a4d6cbaaa28ad50e177fd445ec11d7730ab9b445fcb05b8f480 -name "windows-agent" -webSocket -workDir "C:\jenkins"
```

---

## 5. Paso 4: Configuración del Pipeline (`Jenkinsfile`)
El pipeline automatiza todo el flujo de compilación y despliegue a través del archivo `Jenkinsfile`.
* **Archivo final:** [Jenkinsfile](file:///c:/Users/jmfr1/source/repos/Monolito4toA/Jenkinsfile)

### El Pipeline realiza las siguientes etapas:
1. **Restaurar Paquetes NuGet**: Descarga `nuget.exe` y restaura las dependencias de .NET.
2. **Restaurar Paquetes npm**: Entra a la carpeta del proyecto y ejecuta `npm install --no-audit --no-fund` para garantizar la presencia de archivos frontend (ej. FontAwesome).
3. **Compilar Solución**: Compila el proyecto en configuración `Release` usando MSBuild.
4. **Publicar Aplicación**: Genera el empaquetado del sitio web en una carpeta temporal del espacio de trabajo.
5. **Desplegar en IIS**: Copia todos los archivos procesados directamente al directorio web público de IIS.

---

## 6. Paso 5: Configuración y Permisos de IIS
Para que Jenkins pueda desplegar archivos en el servidor web sin errores de acceso denegado, se deben aplicar los siguientes pasos:

### A. Otorgar Permisos de Escritura al Agente (PowerShell como Administrador)
```powershell
# Crear el directorio del sitio
New-Item -Path "C:\inetpub\wwwroot\Monolito4toA" -ItemType Directory -Force

# Otorgar permisos de Control Total al usuario local sobre esa carpeta
icacls "C:\inetpub\wwwroot\Monolito4toA" /grant "kyomu\jmfr1:(OI)(CI)F" /T
```

### B. Configuración en IIS Manager (`inetmgr`):
1. Abrir **Administrador de IIS**.
2. Clic derecho en **Sitios** ➔ **Agregar sitio web**.
3. Nombre del sitio: `Monolito4toA`.
4. Ruta de acceso física: `C:\inetpub\wwwroot\Monolito4toA`.
5. Asignar un puerto libre (por ejemplo, `8081`).
6. Listo. Acceso desde: **`http://localhost:8081`**.

---

## 7. Guía Rápida de Comandos Docker en PowerShell

### Gestión básica de Contenedores:
```powershell
# Listar contenedores activos
docker ps

# Listar todos los contenedores
docker ps -a

# Apagar Jenkins temporalmente
docker stop jenkins_master

# Volver a encender Jenkins
docker start jenkins_master

# Ver logs en tiempo real
docker logs -f jenkins_master
```

### Inspección y copia de archivos internos del contenedor:
```powershell
# Listar directorio interno
docker exec jenkins_master ls -la /var/jenkins_home

# Entrar a la terminal del contenedor
docker exec -it jenkins_master bash

# Copiar archivos desde Windows al contenedor
docker cp "C:\ruta\origen.txt" jenkins_master:/var/jenkins_home/destino.txt

# Copiar archivos desde el contenedor a Windows
docker cp jenkins_master:/var/jenkins_home/archivo.txt "C:\ruta\destino.txt"
```

### Limpieza de entorno Docker:
```powershell
# Eliminar el contenedor
docker rm -f jenkins_master

# Eliminar el volumen de almacenamiento persistente
docker volume rm monolito4toa_jenkins_data
```

---

## 8. Script de Autenticación de Pruebas Manuales (`run_tests_manual.ps1`)
Hemos adaptado tu plantilla y creado el script de verificación para el proyecto `Monolito4toA`. Este script realiza pruebas rápidas de restauración de paquetes, compilación, validación de estructura de salida y conectividad a SQL Server (`KYOMU\SQLEXPRESS`).

* **Archivo creado:** [run_tests_manual.ps1](file:///c:/Users/jmfr1/source/repos/Monolito4toA/run_tests_manual.ps1)

### Cómo ejecutar las pruebas manuales:
1. Abre **PowerShell como Administrador**.
2. Dirígete a la carpeta del proyecto:
   ```powershell
   cd c:\Users\jmfr1\source\repos\Monolito4toA
   ```
3. Ejecuta el script:
   ```powershell
   .\run_tests_manual.ps1
   ```
