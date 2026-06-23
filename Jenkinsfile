pipeline {
    agent { label 'windows' } // El agente debe ser un nodo Windows que contenga MSBuild y Java

    environment {
        // Ruta al MSBuild que encontramos en tu sistema
        MSBUILD_PATH = 'C:\\Program Files\\Microsoft Visual Studio\\18\\Community\\MSBuild\\Current\\Bin\\MSBuild.exe'
        SOLUTION_NAME = 'Monolito4toA.slnx'
        PROJECT_PATH = 'Monolito4toA\\Monolito4toA.csproj'
        // Ruta destino en IIS
        IIS_PUBLISH_DIR = 'C:\\inetpub\\wwwroot\\Monolito4toA'
    }

    stages {
        stage('Restaurar Paquetes NuGet') {
            steps {
                powershell '''
                Write-Host "Iniciando restauración de paquetes NuGet..."
                
                # Descarga nuget.exe si no existe localmente
                if (-not (Test-Path "nuget.exe")) {
                    Write-Host "nuget.exe no encontrado. Descargando..."
                    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
                }

                # Ejecuta la restauración de la solución
                .\\nuget.exe restore $env:SOLUTION_NAME
                Write-Host "Restauración de paquetes NuGet completada."
                '''
            }
        }

        stage('Compilar Solución') {
            steps {
                powershell '''
                Write-Host "Compilando la solución con MSBuild en modo Release..."
                & "$env:MSBUILD_PATH" $env:SOLUTION_NAME /p:Configuration=Release /p:Platform="Any CPU"
                Write-Host "Compilación completada con éxito."
                '''
            }
        }

        stage('Publicar Aplicación') {
            steps {
                powershell '''
                Write-Host "Publicando aplicación web..."
                # Compilar y publicar el proyecto web a una carpeta temporal
                & "$env:MSBUILD_PATH" $env:PROJECT_PATH /p:Configuration=Release /p:DeployOnBuild=true /p:PublishUrl="$env:WORKSPACE\\publish_output" /p:DeployTarget=WebPublish /p:WebPublishMethod=FileSystem
                Write-Host "Publicación generada en carpetas del workspace."
                '''
            }
        }

        stage('Desplegar en IIS') {
            steps {
                powershell '''
                Write-Host "Desplegando en IIS ($env:IIS_PUBLISH_DIR)..."
                
                # Verifica si la carpeta destino existe, si no la crea
                if (-not (Test-Path $env:IIS_PUBLISH_DIR)) {
                    Write-Host "La ruta destino no existe. Creando directorio..."
                    New-Item -Path $env:IIS_PUBLISH_DIR -ItemType Directory -Force
                }
                
                # Copia los archivos del build temporal a la carpeta pública de IIS
                Copy-Item -Path "$env:WORKSPACE\\publish_output\\*" -Destination $env:IIS_PUBLISH_DIR -Recurse -Force
                
                Write-Host "Despliegue en IIS completado con éxito."
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline ejecutado exitosamente. La aplicación ha sido compilada y desplegada.'
        }
        failure {
            echo 'Error en la ejecución de la compilación o despliegue. Revisa los logs de Jenkins.'
        }
    }
}
