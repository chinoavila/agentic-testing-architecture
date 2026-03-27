#!/usr/bin/env bash
# ATA Hook — Agent-scoped SessionStart: Require STACK.yml configuration
# Used exclusively by TGA, EAA, and ROA agent-scoped hooks.
# Returns continue:false to BLOCK the agent session only when STACK.yml has no configured tools.
# Partial configurations are allowed and should not block agent execution.

STACK_FILE="STACK.yml"

if [ ! -f "$STACK_FILE" ]; then
    printf '{"continue":false,"stopReason":"ATA: STACK.yml no encontrado. Selecciona el agente @ATA Stack Setup desde el selector de agentes del chat para crear y completar el archivo de configuracion de herramientas.","systemMessage":"ATA \u2014 STACK.yml no encontrado. Este agente no puede iniciar sin configuracion. Activa @ATA Stack Setup."}\n'
    exit 0
fi

# Count declared tools and detect how many are empty/non-empty.
TOTAL_TOOL_FIELDS=$(grep -cE '^\s+tool:\s*"[^"]*"\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)
CONFIGURED_TOOL_COUNT=$(grep -cE '^\s+tool:\s*"[^"][^"]*"\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)
EMPTY_COUNT=$((TOTAL_TOOL_FIELDS - CONFIGURED_TOOL_COUNT))

if [ "$TOTAL_TOOL_FIELDS" -eq 0 ] || [ "$CONFIGURED_TOOL_COUNT" -eq 0 ]; then
    printf '{"continue":false,"stopReason":"ATA: STACK.yml no tiene herramientas activas. Abre una nueva sesion de chat y selecciona @ATA Stack Setup para configurar al menos una herramienta antes de usar /TGA, /EAA o /ROA.","systemMessage":"ATA \u2014 Stack sin herramientas activas. Activa @ATA Stack Setup para configurar el proyecto."}\n'
elif [ "$EMPTY_COUNT" -gt 0 ]; then
    printf '{"continue":true,"systemMessage":"ATA \u2014 Stack parcialmente configurado (%s campo(s) vacios). Se continua con las herramientas activas."}\n' "$EMPTY_COUNT"
fi

exit 0
