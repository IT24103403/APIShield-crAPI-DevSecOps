# crAPI Secrets Validation Script

$envFile = Join-Path $PSScriptRoot ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: secrets/.env was not found."
    Write-Host "Copy secrets/.env.example to secrets/.env and configure the values."
    exit 1
}

$requiredVariables = @(
    "POSTGRES_USER",
    "POSTGRES_PASSWORD",
    "MONGO_DB_USER",
    "MONGO_DB_PASSWORD",
    "JWT_SECRET",
    "SECRET_KEY",
    "SMTP_EMAIL",
    "SMTP_PASS",
    "TLS_KEYSTORE_PASSWORD",
    "TLS_KEY_PASSWORD",
    "API_USER",
    "API_PASSWORD"
)

$variables = @{}

Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()

    if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
        $parts = $line.Split("=", 2)
        $variables[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$failed = $false

foreach ($variable in $requiredVariables) {
    if (-not $variables.ContainsKey($variable)) {
        Write-Host "ERROR: Missing required variable: $variable"
        $failed = $true
        continue
    }

    $value = $variables[$variable]

    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Host "ERROR: Empty required variable: $variable"
        $failed = $true
        continue
    }

    if ($value -match "CHANGE_ME") {
        Write-Host "ERROR: Placeholder value detected for: $variable"
        $failed = $true
    }
}

if ($failed) {
    Write-Host ""
    Write-Host "Secrets validation FAILED."
    exit 1
}

Write-Host "Secrets validation PASSED."
Write-Host "Required secret variables are configured."
exit 0