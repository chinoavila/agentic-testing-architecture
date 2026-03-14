# Primeros Pasos

## Configuración Inicial

Antes de invocar cualquier agente, completa `STACK.yml` en la raíz del repositorio con las herramientas de tu proyecto. 
El archivo incluye comentarios inline como guía en cada campo.

### Ejemplo rápido (TypeScript + Playwright + k6)

```yaml
# STACK.yml — fragmento de ejemplo para un proyecto TypeScript + Playwright + k6
project:
  name: "mi-app"
  language: "TypeScript"
  platform: "web"
  base_url_local: "http://localhost:3000"

tga_skills:
  unit_testing:
    tool: "vitest"
    output_ext: ".test.ts"
    skill_file: ".ata/skills/vitest/SKILL.md"
  e2e:
    tool: "playwright"
    output_ext: ".spec.ts"
    skill_file: ".ata/skills/playwright/SKILL.md"
  performance:
    tool: "k6"
    output_ext: ".js"
    skill_file: ""

eaa_skills:
  test_runner:
    tool: "playwright"
    command: "npx playwright test"
    parallel: true
  browser_targets:
    - chromium
    - firefox

roa_skills:
  static_analysis:
    tool: "eslint"
    command: "npx eslint tests/"
    skill_file: ""

naming:
  unit_dir: "src/__tests__"
  e2e_dir: "tests/e2e"
  performance_dir: "tests/performance"
```

Al activar un agente, Copilot lee `STACK.yml`, resuelve qué skills cargar y confirma:

```
[AGENTE ACTIVADO: TGA] — Sesión efímera iniciada.
Stack resuelto: vitest · playwright · k6
```

> Si un campo `tool` está vacío, activa el agente **@ATA Stack Setup** desde el selector del chat.
> Te guiará con una entrevista conversacional para completar `STACK.yml` paso a paso.

### Habilitar hooks en VS Code

Los agent-scoped hooks (que bloquean TGA/EAA/ROA si `STACK.yml` está incompleto) requieren activar la siguiente configuración en VS Code:

```json
// .vscode/settings.json
{
  "chat.useCustomAgentHooks": true
}
```

> La funcionalidad de hooks está en **Preview**. Verificar que esté habilitada en tu organización o en tu entorno local antes de intentar usarla.

---

## Archivos de Configuración

| Archivo | Propósito | Editar |
|---------|-----------|--------|
| `.github/copilot-instructions.md` | Orquestador Pasivo — reglas universales, Matriz de Patrones, Handoff Schema | No |
| `.ata/AGENTS.md` | Registro de protocolos — Role, Trigger, Inputs, Outputs, Handoff Protocol por agente | No |
| `STACK.yml` | Herramientas declaradas del proyecto — resueltas en tiempo de ejecución | **Sí** |
| `.github/agents/stack-setup.agent.md` | Agente efímero de configuración interactiva | No |
| `.github/agents/tga.agent.md` | Definición VS Code del TGA (wrapper del protocolo en `.ata/AGENTS.md`) | No |
| `.github/agents/eaa.agent.md` | Definición VS Code del EAA | No |
| `.github/agents/roa.agent.md` | Definición VS Code del ROA | No |
| `.github/hooks/session-start.json` | Hook workspace SessionStart — advisory (`systemMessage` + `additionalContext`) | No |
| `.ata/hooks/validate-stack.ps1` | Script advisory para el hook de workspace (Windows) | No |
| `.ata/hooks/validate-stack.sh` | Script advisory para el hook de workspace (Linux/macOS) | No |
| `.ata/hooks/require-stack.ps1` | Script bloqueante para agent-scoped hooks de TGA/EAA/ROA (Windows) | No |
| `.ata/hooks/require-stack.sh` | Script bloqueante para agent-scoped hooks de TGA/EAA/ROA (Linux/macOS) | No |
| `.ata/skills/<tool>/SKILL.md` | Instrucciones especializadas por herramienta, una por directorio (carga bajo demanda) | Opcional |

> Los agentes leen `STACK.yml` en cada sesión. El único estado persistente entre sesiones son los artefactos escritos en `/tests/` y `/reports/`.
