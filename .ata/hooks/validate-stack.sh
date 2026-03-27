#!/usr/bin/env bash
# ATA Hook — SessionStart: Validate STACK.yml tool configuration
# Fires at the start of every new agent session.
# Injects an advisory warning when STACK.yml is partially configured, and a stronger warning
# when no tools are configured at all.

STACK_FILE="STACK.yml"

if [ ! -f "$STACK_FILE" ]; then
    printf '{"systemMessage":"ATA: STACK.yml no encontrado. Activa el agente @ATA Stack Setup para crearlo.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[ATA] STACK.yml no encontrado. El agente @ATA Stack Setup puede guiarte para crearlo. Seleccionalo desde el desplegable de agentes del chat."}}\n'
    exit 0
fi

# Count declared tools and detect how many are empty/non-empty.
TOTAL_TOOL_FIELDS=$(grep -cE '^\s+tool:\s*"[^"]*"\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)
CONFIGURED_TOOL_COUNT=$(grep -cE '^\s+tool:\s*"[^"][^"]*"\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)
EMPTY_COUNT=$((TOTAL_TOOL_FIELDS - CONFIGURED_TOOL_COUNT))

if [ "$TOTAL_TOOL_FIELDS" -gt 0 ] && [ "$CONFIGURED_TOOL_COUNT" -eq 0 ]; then
    printf '{"systemMessage":"ATA - Stack sin configurar (0 herramientas activas): activa el agente @ATA Stack Setup para la entrevista guiada.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[ATA - SessionStart] STACK.yml no tiene herramientas activas. Antes de procesar /TGA, /EAA o /ROA, indica al usuario que active @ATA Stack Setup para completar la configuracion interactivamente."}}\n'
elif [ "$EMPTY_COUNT" -gt 0 ]; then
    printf '{"systemMessage":"ATA - Stack parcialmente configurado (%s campo(s) vacios): se puede continuar con las herramientas activas.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[ATA - SessionStart] STACK.yml tiene %s campo(s) tool vacios, pero tambien herramientas configuradas. No bloquees la ejecucion: continua con los agentes y sugiere @ATA Stack Setup solo si el usuario necesita completar esos casos."}}\n' "$EMPTY_COUNT" "$EMPTY_COUNT"
fi

exit 0
