# ATA Hook — SessionStart: Validate STACK.yml tool configuration
# Fires at the start of every new agent session.
# Injects an advisory warning when STACK.yml is partially configured, and a stronger warning
# when no tools are configured at all.

$stackPath = "STACK.yml"

if (-not (Test-Path $stackPath)) {
    [PSCustomObject]@{
        systemMessage      = "ATA: STACK.yml no encontrado. Activa el agente @ATA Stack Setup para crearlo."
        hookSpecificOutput = [PSCustomObject]@{
            hookEventName     = "SessionStart"
            additionalContext = "[ATA] STACK.yml no encontrado. El agente @ATA Stack Setup puede guiarte para crearlo desde cero. Seleccionalo desde el desplegable de agentes en el chat."
        }
    } | ConvertTo-Json -Compress -Depth 3
    exit 0
}

$content = Get-Content $stackPath -Raw -Encoding UTF8

# Count declared tools and detect how many are empty/non-empty.
$toolMatches = [regex]::Matches($content, '(?m)^\s+tool:\s*"([^"]*)"\s*(?:#.*)?$')
$totalToolFields = $toolMatches.Count
$configuredToolCount = @($toolMatches | Where-Object { $_.Groups[1].Value.Trim().Length -gt 0 }).Count
$emptyCount = $totalToolFields - $configuredToolCount

if ($totalToolFields -gt 0 -and $configuredToolCount -eq 0) {
    [PSCustomObject]@{
        systemMessage      = "ATA - Stack sin configurar (0 herramientas activas): activa el agente @ATA Stack Setup para la entrevista guiada."
        hookSpecificOutput = [PSCustomObject]@{
            hookEventName     = "SessionStart"
            additionalContext = "[ATA - SessionStart] STACK.yml no tiene herramientas activas. Antes de procesar /TGA, /EAA o /ROA, indica al usuario que active @ATA Stack Setup para completar la configuracion interactivamente."
        }
    } | ConvertTo-Json -Compress -Depth 3
}
elseif ($emptyCount -gt 0) {
    [PSCustomObject]@{
        systemMessage      = "ATA - Stack parcialmente configurado ($emptyCount campo(s) vacios): se puede continuar con las herramientas activas."
        hookSpecificOutput = [PSCustomObject]@{
            hookEventName     = "SessionStart"
            additionalContext = "[ATA - SessionStart] STACK.yml tiene $emptyCount campo(s) 'tool:' vacios, pero tambien herramientas configuradas. No bloquees la ejecucion: continua con los agentes y sugiere @ATA Stack Setup solo si el usuario necesita completar esos casos."
        }
    } | ConvertTo-Json -Compress -Depth 3
}

exit 0
