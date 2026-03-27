# Primeros Pasos

## Configuración Inicial

Antes de invocar cualquier agente, completa `STACK.yml` en la raíz del repositorio con las herramientas de tu proyecto. 
El archivo incluye comentarios inline como guía en cada campo.

ATA Stack Setup debe crear las skills de herramientas de forma obligatoria
para cada `tool` configurada (incluyendo contenedores y orquestadores si existen).

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
    skill_file: ".github/skills/vitest/SKILL.md"
  e2e:
    tool: "playwright"
    output_ext: ".spec.ts"
    skill_file: ".github/skills/playwright/SKILL.md"
  performance:
    tool: "k6"
    output_ext: ".js"
    skill_file: ".github/skills/k6/SKILL.md"

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

container_skills:
  container_runtime:
    tool: "docker"
    command: "docker"
    skill_file: ".github/skills/docker/SKILL.md"
  compose_orchestrator:
    tool: "docker compose"
    command: "docker compose -f docker-compose.yml up -d"
    compose_file: "docker-compose.yml"
    skill_file: ".github/skills/docker-compose/SKILL.md"
  kubernetes_orchestrator:
    tool: "kubectl"
    command: "kubectl apply -f k8s/"
    namespace: "testing"
    manifests_path: "k8s/"
    skill_file: ".github/skills/kubectl/SKILL.md"

naming:
  unit_dir: "src/__tests__"
  integration_dir: "tests/integration"
  e2e_dir: "tests/e2e"
  performance_dir: "tests/performance"
```

### Soporte de contenedores (Docker/Compose/Podman/Kubernetes)

ATA resuelve estas herramientas desde `STACK.yml → container_skills` para que EAA u ORCA
puedan ejecutar pruebas sobre ambientes containerizados en lugar del host local.

- `container_runtime.tool`: runtime base (`docker` o `podman`)
- `compose_orchestrator.tool`: orquestador por Compose (`docker-compose`, `docker compose`, `podman-compose`)
- `kubernetes_orchestrator.tool`: orquestador para clúster (`kubectl`, `helm`, `kustomize`)

Si no usás contenedores, podés dejar estos campos vacíos sin afectar el flujo ATA clásico.

Al activar un agente, Copilot lee `STACK.yml`, resuelve qué skills cargar y confirma:

```
[AGENTE ACTIVADO: TGA] — Sesión efímera iniciada.
Stack resuelto: vitest · playwright · k6
```

> Si STACK.yml **no tiene ninguna herramienta activa**, los agentes ORCA/TGA/EAA/ROA detectan
> la condición en el hook de sesión y presentan el handoff **Configurar stack con ATA Stack Setup**
> para iniciar la configuración interactiva sin necesidad de abrir una nueva sesión.
> Si STACK.yml tiene **herramientas parcialmente configuradas**, los agentes continúan normalmente
> con las herramientas activas y sugieren completar la configuración solo si es necesario.

### Habilitar hooks en VS Code

Los agent-scoped hooks (que redirigen ORCA/TGA/EAA/ROA al asistente de configuración cuando
`STACK.yml` no tiene herramientas activas) requieren activar la siguiente configuración en VS Code:

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
| `.github/agents/orca.agent.md` | Orchestrator Agent — CCV automático end-to-end (`/ORC`) | No |
| `.github/agents/tga.agent.md` | Definición VS Code del TGA — flujo manual (`/TGA`) | No |
| `.github/agents/eaa.agent.md` | Definición VS Code del EAA — flujo manual (`/EAA`) | No |
| `.github/agents/roa.agent.md` | Definición VS Code del ROA — flujo manual (`/ROA`) | No |
| `.github/hooks/session-start.json` | Hook workspace SessionStart — advisory (`systemMessage` + `additionalContext`) | No |
| `.ata/hooks/validate-stack.ps1` | Script advisory para el hook de workspace (Windows) | No |
| `.ata/hooks/validate-stack.sh` | Script advisory para el hook de workspace (Linux/macOS) | No |
| `.ata/hooks/require-stack.ps1` | Script de redirección para agent-scoped hooks de ORCA/TGA/EAA/ROA (Windows): si STACK.yml no tiene herramientas activas, instruye al agente a presentar el handoff **Configurar stack con ATA Stack Setup** en lugar de ejecutar el flujo normal | No |
| `.ata/hooks/require-stack.sh` | Script de redirección para agent-scoped hooks de ORCA/TGA/EAA/ROA (Linux/macOS): misma lógica que el script .ps1 | No |
| `.github/skills/<tool>/SKILL.md` | Instrucciones especializadas por herramienta, una por directorio (carga bajo demanda) | Sí |

> Los agentes leen `STACK.yml` en cada sesión. El único estado persistente entre sesiones son los artefactos escritos en `/tests/` y `/reports/`.
