@ECHO off
cd /D "%~dp0"

FOR /F "tokens=* USEBACKQ" %%F IN (`CALL ..\get_version.bat`) DO SET version=%%F
ECHO version=%version%

IF NOT EXIST debug-info mkdir debug-info

for /F "tokens=1,2*" %%i in (..\android-implementations.txt) do (
  ECHO *** Compilando %%i...

  @CALL flutter clean

  @CALL flutter build apk --obfuscate --split-debug-info=.\debug-info\%version%-%%i --dart-define=IMPLEMENTATION=%%i --target-platform=%%j

  @CALL move .\build\app\outputs\flutter-apk\app-release.apk ".\agnostiko_example-%version%-%%i.apk"

  ECHO *** Listo %%i!
)

ECHO Compilaciones exitosas!

:end
