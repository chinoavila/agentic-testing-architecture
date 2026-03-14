# ATA Hook — SessionStart: Validate STACK.yml tool configuration
# Fires at the start of every new agent session.
# Injects a warning into the conversation if any 'tool:' field in STACK.yml is unconfigured.

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

# Match lines of the form:  tool: ""  (with optional inline comment)
$emptyCount = ([regex]'(?m)^\s+tool:\s*""\s*(?:#.*)?$').Matches($content).Count

if ($emptyCount -gt 0) {
    [PSCustomObject]@{
        systemMessage      = "ATA - Stack sin configurar ($emptyCount campo(s) vacios): activa el agente @ATA Stack Setup para la entrevista guiada."
        hookSpecificOutput = [PSCustomObject]@{
            hookEventName     = "SessionStart"
            additionalContext = "[ATA - SessionStart] STACK.yml tiene $emptyCount campo(s) 'tool:' vacios. Antes de procesar cualquier solicitud /TGA, /EAA o /ROA, indica al usuario que active el agente @ATA Stack Setup desde el selector de agentes del chat para completar la configuracion interactivamente."
        }
    } | ConvertTo-Json -Compress -Depth 3
}

exit 0
