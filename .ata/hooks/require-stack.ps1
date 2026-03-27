# ATA Hook - Agent-scoped SessionStart: Require STACK.yml configuration
# Used exclusively by TGA, EAA, ROA, and ORCA agent-scoped hooks.
# When STACK.yml has no configured tools, returns continue:true with a systemMessage that
# instructs the agent to redirect the user to the 'ATA Stack Setup' handoff instead of
# running the normal flow. Partial configurations are allowed and do not block execution.

$stackPath = "STACK.yml"

if (-not (Test-Path $stackPath)) {
    [PSCustomObject]@{
        continue      = $true
        systemMessage = "ATA - STACK.yml no encontrado. INSTRUCCION OBLIGATORIA: NO ejecutes el flujo normal de este agente. En su lugar: (1) informa al usuario que STACK.yml no existe y que el CCV no puede iniciarse sin el, (2) usa INMEDIATAMENTE el handoff 'Configurar stack con ATA Stack Setup' disponible en esta sesion para crear el archivo de configuracion de forma interactiva, (3) no ejecutes ninguna fase del CCV hasta que el stack este creado y la sesion sea reiniciada."
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
        continue      = $true
        systemMessage = "ATA - STACK.yml no tiene herramientas activas. INSTRUCCION OBLIGATORIA: NO ejecutes el flujo normal de este agente. En su lugar: (1) informa al usuario que STACK.yml esta sin configurar y que el CCV no puede iniciarse, (2) usa INMEDIATAMENTE el handoff 'Configurar stack con ATA Stack Setup' disponible en esta sesion para iniciar la configuracion interactiva, (3) no ejecutes ninguna fase del CCV hasta que el stack este configurado y la sesion sea reiniciada."
    } | ConvertTo-Json -Compress -Depth 2
}
elseif ($emptyCount -gt 0) {
    [PSCustomObject]@{
        continue   = $true
        systemMessage = "ATA - Stack parcialmente configurado ($emptyCount campo(s) vacios). Se continua con las herramientas activas."
    } | ConvertTo-Json -Compress -Depth 2
}

exit 0
