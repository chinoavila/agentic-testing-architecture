# ATA Hook — Agent-scoped SessionStart: Require STACK.yml configuration
# Used exclusively by TGA, EAA, and ROA agent-scoped hooks.
# Returns continue:false to BLOCK the agent session when STACK.yml has unconfigured tool fields,
# forcing the developer to activate @ATA Stack Setup before proceeding.

$stackPath = "STACK.yml"

if (-not (Test-Path $stackPath)) {
    [PSCustomObject]@{
        continue   = $false
        stopReason = "ATA: STACK.yml no encontrado. Selecciona el agente @ATA Stack Setup desde el selector de agentes del chat para crear y completar el archivo de configuracion de herramientas."
        systemMessage = "ATA — STACK.yml no encontrado. Este agente no puede iniciar sin configuracion. Activa @ATA Stack Setup."
    } | ConvertTo-Json -Compress -Depth 2
    exit 0
}

$content = Get-Content $stackPath -Raw -Encoding UTF8

# Match lines of the form:  tool: ""  (with optional inline comment)
$emptyCount = ([regex]'(?m)^\s+tool:\s*""\s*(?:#.*)?$').Matches($content).Count

if ($emptyCount -gt 0) {
    [PSCustomObject]@{
        continue   = $false
        stopReason = "ATA: STACK.yml tiene $emptyCount campo(s) 'tool:' sin configurar. Abre una nueva sesion de chat y selecciona el agente @ATA Stack Setup para completar la configuracion interactivamente antes de usar /TGA, /EAA o /ROA."
        systemMessage = "ATA — Stack incompleto ($emptyCount campo(s) vacios). Activa @ATA Stack Setup para configurar las herramientas del proyecto."
    } | ConvertTo-Json -Compress -Depth 2
}

exit 0
