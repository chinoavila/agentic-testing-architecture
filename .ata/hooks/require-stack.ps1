# ATA Hook - Agent-scoped SessionStart: Require STACK.yml configuration
# Used exclusively by TGA, EAA, and ROA agent-scoped hooks.
# Returns continue:false to BLOCK the agent session only when STACK.yml has no configured tools.
# Partial configurations are allowed and should not block agent execution.

$stackPath = "STACK.yml"

if (-not (Test-Path $stackPath)) {
    [PSCustomObject]@{
        continue   = $false
        stopReason = "ATA: STACK.yml no encontrado. Selecciona el agente @ATA Stack Setup desde el selector de agentes del chat para crear y completar el archivo de configuracion de herramientas."
        systemMessage = "ATA - STACK.yml no encontrado. Este agente no puede iniciar sin configuracion. Activa @ATA Stack Setup."
    } | ConvertTo-Json -Compress -Depth 2
    exit 0
}

$content = Get-Content $stackPath -Raw -Encoding UTF8

# Count declared tools and detect how many are empty/non-empty.
$toolMatches = [regex]::Matches($content, '(?m)^\s+tool:\s*"([^"]*)"\s*(?:#.*)?$')
$totalToolFields = $toolMatches.Count
$configuredToolCount = @($toolMatches | Where-Object { $_.Groups[1].Value.Trim().Length -gt 0 }).Count
$emptyCount = $totalToolFields - $configuredToolCount

if ($totalToolFields -eq 0 -or $configuredToolCount -eq 0) {
    [PSCustomObject]@{
        continue   = $false
        stopReason = "ATA: STACK.yml no tiene herramientas activas. Abre una nueva sesion de chat y selecciona @ATA Stack Setup para configurar al menos una herramienta antes de usar /TGA, /EAA o /ROA."
        systemMessage = "ATA - Stack sin herramientas activas. Activa @ATA Stack Setup para configurar el proyecto."
    } | ConvertTo-Json -Compress -Depth 2
}
elseif ($emptyCount -gt 0) {
    [PSCustomObject]@{
        continue   = $true
        systemMessage = "ATA - Stack parcialmente configurado ($emptyCount campo(s) vacios). Se continua con las herramientas activas."
    } | ConvertTo-Json -Compress -Depth 2
}

exit 0
