@ECHO off

if "%~1"=="" (
    echo Falta el parametro para 'app_name'.
    goto end
) 
SET app_name=%1
if "%~2"=="" (
    echo Falta el parametro para 'version'.
    goto end
) 
SET version=%2
if "%~3"=="" (
    echo Falta el parametro para 'company_name'.
    goto end
) 
SET company_name=%3

set year=%date:~10,4%
set month=%date:~4,2%
set day=%date:~7,2%

echo build\flutter_assets> .\build\filepath.txt
echo build\embedder>> .\build\filepath.txt
echo build\icudtl.dat>> .\build\filepath.txt
echo build\roboto.ttf>> .\build\filepath.txt
echo build\app.so	%version%	private>> .\build\filepath.txt
echo build\libflutter_engine.so 	%version%	private>> .\build\filepath.txt
echo build\libmdb.so 	%version%	private>> .\build\filepath.txt
echo build\libstm32down.so 	%version%	private>> .\build\filepath.txt
echo build\libemvl3.so 	%version%	private>> .\build\filepath.txt

echo [param]> .\build\param.ini
echo Name = %app_name%>> .\build\param.ini
echo RootAppFlag = 0 >> .\build\param.ini
echo Version = %version%>> .\build\param.ini
echo Main = embedder>> .\build\param.ini
echo Icon = >> .\build\param.ini
echo MasterApp = 0 >> .\build\param.ini
echo ReleaseDate = %year%%month%%day%>> .\build\param.ini
echo Company = %company_name%>> .\build\param.ini
echo PackType = F>> .\build\param.ini

@CALL C:\NPT_SDK\Common\tools\Package_Generator\pkgNLD\upt.exe -h .\build\filepath.txt -p .\build\param.ini -o app-%version%.NLD
