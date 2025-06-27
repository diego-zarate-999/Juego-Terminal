@ECHO off

@IF "%FLUTTER_ROOT%"=="" (
ECHO La variable de entorno 'FLUTTER_ROOT' no esta definida! Debe definir la ruta de su instalacion de Flutter.
exit
)

FOR /F "tokens=* USEBACKQ" %%x IN (`type %FLUTTER_ROOT%\version`) DO SET flutter_version=%%x

ECHO %flutter_version%
