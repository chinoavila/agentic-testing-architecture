#!/usr/bin/env bash
# ATA Hook — Agent-scoped SessionStart: Require STACK.yml configuration
# Used exclusively by TGA, EAA, ROA, and ORCA agent-scoped hooks.
# When STACK.yml has no configured tools, returns continue:true with a systemMessage that
# instructs the agent to redirect the user to the 'ATA Stack Setup' handoff instead of
# running the normal flow. Partial configurations are allowed and do not block execution.

STACK_FILE="STACK.yml"

if [ ! -f "$STACK_FILE" ]; then
    printf '{"continue":true,"systemMessage":"ATA - STACK.yml no encontrado. INSTRUCCION OBLIGATORIA: NO ejecutes el flujo normal de este agente. En su lugar: (1) informa al usuario que STACK.yml no existe y que el CCV no puede iniciarse sin el, (2) usa INMEDIATAMENTE el handoff Configurar stack con ATA Stack Setup disponible en esta sesion para crear el archivo de configuracion de forma interactiva, (3) no ejecutes ninguna fase del CCV hasta que el stack este creado y la sesion sea reiniciada."}\n'
    exit 0
fi

# Count declared tools and detect how many are empty/non-empty.
TOTAL_TOOL_FIELDS=$(grep -cE '^\s+tool:\s*"[^"]*"\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)
CONFIGURED_TOOL_COUNT=$(grep -cE '^\s+tool:\s*"[^"][^"]*"\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)
EMPTY_COUNT=$((TOTAL_TOOL_FIELDS - CONFIGURED_TOOL_COUNT))

if [ "$TOTAL_TOOL_FIELDS" -eq 0 ] || [ "$CONFIGURED_TOOL_COUNT" -eq 0 ]; then
    printf '{"continue":true,"systemMessage":"ATA - STACK.yml no tiene herramientas activas. INSTRUCCION OBLIGATORIA: NO ejecutes el flujo normal de este agente. En su lugar: (1) informa al usuario que STACK.yml esta sin configurar y que el CCV no puede iniciarse, (2) usa INMEDIATAMENTE el handoff Configurar stack con ATA Stack Setup disponible en esta sesion para iniciar la configuracion interactiva, (3) no ejecutes ninguna fase del CCV hasta que el stack este configurado y la sesion sea reiniciada."}\n'
elif [ "$EMPTY_COUNT" -gt 0 ]; then
    printf '{"continue":true,"systemMessage":"ATA \u2014 Stack parcialmente configurado (%s campo(s) vacios). Se continua con las herramientas activas."}\n' "$EMPTY_COUNT"
fi

exit 0
