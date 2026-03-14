#!/usr/bin/env bash
# ATA Hook — Agent-scoped SessionStart: Require STACK.yml configuration
# Used exclusively by TGA, EAA, and ROA agent-scoped hooks.
# Returns continue:false to BLOCK the agent session when STACK.yml has unconfigured tool fields,
# forcing the developer to activate @ATA Stack Setup before proceeding.

STACK_FILE="STACK.yml"

if [ ! -f "$STACK_FILE" ]; then
    printf '{"continue":false,"stopReason":"ATA: STACK.yml no encontrado. Selecciona el agente @ATA Stack Setup desde el selector de agentes del chat para crear y completar el archivo de configuracion de herramientas.","systemMessage":"ATA \u2014 STACK.yml no encontrado. Este agente no puede iniciar sin configuracion. Activa @ATA Stack Setup."}\n'
    exit 0
fi

# Count lines matching:  tool: ""  (with optional inline comment)
EMPTY_COUNT=$(grep -cE '^\s+tool:\s*""\s*(#.*)?$' "$STACK_FILE" 2>/dev/null || echo 0)

if [ "$EMPTY_COUNT" -gt 0 ]; then
    printf '{"continue":false,"stopReason":"ATA: STACK.yml tiene %s campo(s) tool sin configurar. Abre una nueva sesion de chat y selecciona el agente @ATA Stack Setup para completar la configuracion interactivamente antes de usar /TGA, /EAA o /ROA.","systemMessage":"ATA \u2014 Stack incompleto (%s campo(s) vacios). Activa @ATA Stack Setup para configurar las herramientas del proyecto."}\n' "$EMPTY_COUNT" "$EMPTY_COUNT"
fi

exit 0
