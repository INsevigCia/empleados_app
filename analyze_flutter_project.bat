@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: 1. Configuración robusta
set PROJECT_DIR=%~dp0
set LOG_FILE=%PROJECT_DIR%flutter_analysis_%date:~-4,4%%date:~-7,2%%date:~-10,2%.log
set FLUTTER_CMD=flutter
set ERROR_FLAG=0

:: 2. Verificación mejorada del entorno
title Análisis Flutter - %PROJECT_DIR%

:: 3. Comprobar ubicación correcta
if not exist "%PROJECT_DIR%pubspec.yaml" (
    echo.
    echo ERROR: No se encontró pubspec.yaml
    echo El script debe ejecutarse en la raíz del proyecto Flutter
    echo Directorio actual: %PROJECT_DIR%
    echo.
    pause
    exit /b 1
)

:: 4. Iniciar análisis con mejor control de errores
(
    echo === ANÁLISIS INICIADO ===
    echo Fecha: %date% %time%
    echo Proyecto: %PROJECT_DIR%
    echo.

    :: 5. Información del sistema
    echo [1/10] SISTEMA
    ver
    echo FLUTTER:
    %FLUTTER_CMD% --version
    echo.

    :: 6. Estructura crítica del proyecto
    echo [2/10] ESTRUCTURA
    echo LIB:
    dir /a-d /s /b "%PROJECT_DIR%lib\*.dart" | find /c /v ""
    echo ANDROID:
    dir "%PROJECT_DIR%android\app\src\main\AndroidManifest.xml" || echo ERROR: No existe AndroidManifest.xml
    echo.

    :: 7. Dependencias (con manejo de errores)
    echo [3/10] DEPENDENCIAS
    %FLUTTER_CMD% pub outdated || set ERROR_FLAG=1
    echo.
    %FLUTTER_CMD% pub deps --style=compact || set ERROR_FLAG=1
    echo.

    :: 8. Análisis de código
    echo [4/10] ANÁLISIS DE CÓDIGO
    %FLUTTER_CMD% analyze || set ERROR_FLAG=1
    echo.

    :: 9. Configuración Android
    echo [5/10] CONFIGURACIÓN ANDROID
    if exist "%PROJECT_DIR%android\app\build.gradle" (
        echo minSdkVersion:
        findstr "minSdkVersion" "%PROJECT_DIR%android\app\build.gradle"
        echo targetSdkVersion:
        findstr "targetSdkVersion" "%PROJECT_DIR%android\app\build.gradle"
        echo proguard:
        findstr "proguard" "%PROJECT_DIR%android\app\build.gradle" || echo No hay reglas ProGuard
    ) else (
        echo ERROR: No existe build.gradle
        set ERROR_FLAG=1
    )
    echo.

    :: 10. Builds de prueba
    echo [6/10] BUILD DEBUG
    %FLUTTER_CMD% build apk --debug || (
        echo ERROR: Falló build debug
        set ERROR_FLAG=1
    )
    echo.

    echo [7/10] BUILD RELEASE
    %FLUTTER_CMD% build apk --release --no-shrink || (
        echo ERROR: Falló build release
        set ERROR_FLAG=1
    )
    echo.

    :: 11. Resumen ejecutivo
    echo === RESUMEN ===
    if %ERROR_FLAG%==1 (
        echo SE DETECTARON PROBLEMAS
    ) else (
        echo SIN ERRORES CRÍTICOS DETECTADOS
    )
    echo.
    echo Análisis completo: %LOG_FILE%
) > "%LOG_FILE%" 2>&1

:: 12. Mostrar resultados clave
echo.
echo RESULTADOS DEL ANÁLISIS:
echo ------------------------
type "%LOG_FILE%" | findstr /B /C:"ERROR" /C:"SE DETECTARON" /C:"flutter" /C:"=== RESUMEN" /C:"Analisis completo" || echo No se encontraron errores críticos

:: 13. Mantener abierto y opciones
echo.
echo OPCIONES:
echo 1. Abrir log completo
echo 2. Salir
set /p choice="Seleccione opción [1-2]: "

if "%choice%"=="1" (
    start notepad "%LOG_FILE%"
)

:: Limpieza final
ENDLOCAL