@ECHO off

@IF "%FLUTTER_ROOT%"=="" (
ECHO La variable de entorno 'FLUTTER_ROOT' no esta definida! Debe definir la ruta de su instalacion de Flutter.
exit
)

@CALL flutter pub get

@if not exist ".\build" mkdir build

ECHO *** Copiando embedder...

rem copiamos los archivos binarios del embedder
@xcopy /s/y %~dp0..\bin\ .\build\

ECHO *** Compilando app...

rem compilamos el código dart a '.dill' para poder luego generar el snapshot en código máquina
@CALL "%FLUTTER_ROOT%\bin\cache\dart-sdk\bin\dart.exe" --disable-dart-dev "%FLUTTER_ROOT%\bin\cache\artifacts\engine\windows-x64\frontend_server.dart.snapshot" --sdk-root "%FLUTTER_ROOT%\bin\cache\artifacts\engine\common\flutter_patched_sdk_product/" --target=flutter --no-print-incremental-dependencies "-Ddart.vm.profile=false" "-Ddart.vm.product=true" --aot --tfa --packages .\.dart_tool\package_config.json --output-dill .\build\app.dill --depfile .\build\kernel_snapshot.d .\lib\main.dart

rem copiamos temporalmente el gen_snapshot para compilar bajo wsl en la carpeta del proyecto
@copy %~dp0..\bin\gen_snapshot .
