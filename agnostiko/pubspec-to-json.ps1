$data_list = (Get-Content -Path ".\pubspec.yaml" | ConvertFrom-Yaml -Ordered)
Set-Content -Path ".\pubspec.json" -Value ($data_list | ConvertTo-Json -Depth 4)
