@ECHO off

FOR /F "tokens=* USEBACKQ" %%F IN (`findstr version %~dp0\pubspec.yaml`) DO (
  SET version_line=%%F
)

for /F "tokens=2 delims= " %%a in ("%version_line%") do SET version=%%a
ECHO %version%
ECHO "AGNOSTIKO_VERSION=$(echo %version%)" >> $Env:GITHUB_ENV
