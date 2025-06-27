$version_line = Select-String -Path .\pubspec.yaml -Pattern "version:"
$version = $version_line.Line.Split(":")[1].Trim()
echo $version
