./pubspec-to-json.ps1
$version = (./get_version.ps1)
$hash = (Get-FileHash agnostiko-$version.tar.gz).Hash.ToLower()

$(echo "{"
  echo "`"version`":`"$version`","
  echo '"archive_url":"",' 
  echo "`"archive_sha256`":`"$hash`","
  echo '"pubspec":' 
  Get-Content .\pubspec.json 
  echo '}' 
) | Set-Content pub.json
