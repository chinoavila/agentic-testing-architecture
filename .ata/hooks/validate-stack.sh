#!/usr/bin/env bash
# ATA Hook — SessionStart: Validate STACK.yml tool configuration
# Fires at the start of every new agent session.
# Injects a warning into the conversation if any 'tool:' field in STACK.yml is unconfigured.

STACK_FILE="STACK.yml"

if [ ! -f "$STACK_FILE" ]; then
    printf '{"systemMessage":"ATA: STACK.yml no encontrado. Activa el agente @ATA Stack Setup para crearlo.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[ATA] STACK.yml no encontrado. El agente @ATA Stack Setup puede guiarte para crearlo. Seleccionalo desde el desplegable de agentes del chat."}}\n'
    exit 0
fi

# Count lines matching:  tool: ""  (with optional inline comment)
EMPTY_COUNT=$(grep -cE '^\s+tool:\s*""\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)

if [ "$EMPTY_COUNT" -gt 0 ]; then
    printf '{"systemMessage":"ATA - Stack sin configurar (%s campo(s) vacios): activa el agente @ATA Stack Setup para la entrevista guiada.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[ATA - SessionStart] STACK.yml tiene %s campo(s) tool vacios. Antes de procesar solicitudes /TGA, /EAA o /ROA, indica al usuario que active el agente @ATA Stack Setup desde el selector de agentes para la entrevista interactiva."}}\n' "$EMPTY_COUNT" "$EMPTY_COUNT"
fi

exit 0
