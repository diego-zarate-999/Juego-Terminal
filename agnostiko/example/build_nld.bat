@ECHO off
cd /D "%~dp0"

FOR /F "tokens=* USEBACKQ" %%F IN (`CALL ..\get_version.bat`) DO SET version=%%F
ECHO version=%version%

@call flutter clean
@call flutter pub get
:: Requiere agnostiko_scripts 2.0+
@call flutter pub global run agnostiko_scripts:build_nld --app-name=agnostiko_example --version=%version% --company-name=APPS2GO
