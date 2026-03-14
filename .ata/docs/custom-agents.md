# Custom Agents de VS Code Copilot

## ¿Qué son los Custom Agents?

Los **Custom Agents** son configuraciones de IA persistentes que adoptan una identidad específica —con instrucciones, herramientas y modelo de lenguaje propios— cada vez que el usuario los selecciona en el chat. A diferencia de un prompt ocasional, un agente personalizado define *cómo* responde la IA de forma consistente en todas las conversaciones que lo usen.

Un agente se define en un archivo **`.agent.md`**: un archivo Markdown con frontmatter YAML opcional que declara sus capacidades, y un cuerpo con sus instrucciones detalladas.

> VS Code detecta automáticamente cualquier archivo `.md` dentro de `.github/agents/` del workspace como un agente personalizado.

---

## ¿Cuándo usar Custom Agents?

| Necesidad | Solución recomendada |
|-----------|----------------------|
| Persona persistente con herramientas restringidas | ✅ **Custom Agent** |
| Transición guiada entre roles (plan → implement) | ✅ **Custom Agent** + Handoffs |
| Tarea única que no requiere restricción de tools | Prompt file |
| Capacidades reutilizables con scripts y recursos | Agent Skill |

---

## Ubicaciones de los archivos `.agent.md`

| Ámbito | Carpeta |
|--------|---------|
| Workspace (formato VS Code) | `.github/agents/` |
| Workspace (formato Claude) | `.claude/agents/` |
| Perfil de usuario (global) | `~/.copilot/agents/` o carpeta `agents/` del perfil activo de VS Code |

Se pueden agregar ubicaciones adicionales con el setting `chat.agentFilesLocations`.

---

## Estructura del archivo `.agent.md`

### Encabezado (frontmatter YAML — opcional)

```yaml
---
name: "Nombre del agente"
description: "Descripción breve mostrada como placeholder en el chat"
argument-hint: "Hint para guiar al usuario al invocar el agente"
tools:
  - read_file
  - grep_search
  - create_file
agents:
  - OtroAgente
model: "Claude Sonnet 4.5 (copilot)"
user-invocable: true
disable-model-invocation: false
handoffs:
  - label: "Ir a Implementación"
    agent: implementation
    prompt: "Ahora implementá el plan detallado arriba."
    send: false
hooks:
  SessionStart:
    - type: command
      command: "bash .ata/hooks/require-stack.sh"
      windows: "powershell -ExecutionPolicy Bypass -NoProfile -File .ata\\hooks\\require-stack.ps1"
      cwd: "."
      timeout: 10
---
```

### Tabla de propiedades del frontmatter

| Propiedad | Descripción |
|-----------|-------------|
| `name` | Nombre del agente. Si se omite, se usa el nombre del archivo. |
| `description` | Texto breve mostrado como placeholder en el input del chat. |
| `argument-hint` | Texto de ayuda que aparece en el input al invocar el agente. |
| `tools` | Lista de herramientas disponibles para el agente (built-in, MCP, extensions). Usar `<server>/*` para incluir todos los tools de un servidor MCP. |
| `agents` | Lista de subagentes disponibles. Usar `*` para permitir todos, `[]` para ninguno. Requiere incluir `agent` en `tools`. |
| `model` | Modelo de lenguaje a usar. Puede ser un string o un array en orden de prioridad. Formato: `Nombre del Modelo (vendor)`. |
| `user-invocable` | Controla si el agente aparece en el dropdown de agentes (default: `true`). `false` lo oculta pero lo mantiene disponible como subagente. |
| `disable-model-invocation` | Impide que otros agentes lo invoquen como subagente (default: `false`). |
| `target` | Entorno destino: `vscode` o `github-copilot`. |
| `handoffs` | Lista de transiciones sugeridas hacia otros agentes (ver sección Handoffs). |
| `hooks` (Preview) | Hooks scoped a este agente. Requiere `chat.useCustomAgentHooks: true`. Mismo formato que archivos de configuración de hooks. |

### Cuerpo (body)

El cuerpo del archivo contiene las instrucciones del agente en Markdown. Se antepone automáticamente al prompt del usuario en cada conversación.

- Referenciá otros archivos con links Markdown estándar.
- Referenciá herramientas en el texto usando `#tool:<nombre>` (ej.: `#tool:githubRepo`).
- Incluí contexto, restricciones, ejemplos y reglas de comportamiento.

### Ejemplo mínimo

```markdown
---
description: Analiza vulnerabilidades de seguridad en el código
tools:
  - read_file
  - grep_search
  - semantic_search
---

Eres un revisor de seguridad especializado en OWASP Top 10.
Para cada archivo que analices, verificá:
1. Inyección (SQL, XSS, command injection)
2. Control de acceso roto
3. Fallos criptográficos
4. Configuración insegura

Siempre citá la línea exacta y el CWE correspondiente.
```

---

## Handoffs

Los **Handoffs** permiten crear flujos de trabajo guiados entre agentes. Al completar una respuesta, VS Code muestra botones de "siguiente paso" que llevan al usuario al agente destino con contexto y un prompt pre-completado.

### Cuándo usar Handoffs

- **Planificación → Implementación**: el agente de diseño genera el plan; el handoff transfiere al agente de implementación.
- **Implementación → Revisión**: el agente de codificación termina; el handoff activa el revisor de calidad.
- **Tests fallidos → Tests pasando**: el agente escribe tests que fallan; el handoff activa al agente que los hace pasar implementando el código.

### Propiedades de un Handoff

| Propiedad | Descripción |
|-----------|-------------|
| `label` | Texto del botón que ve el usuario. |
| `agent` | Identificador del agente destino (nombre del archivo sin extensión). |
| `prompt` | Prompt que se pre-completa en el chat al hacer el handoff. |
| `send` | `true` para enviar el prompt automáticamente (default: `false`). |
| `model` | Modelo opcional a usar cuando se ejecuta el handoff. |

### Ejemplo de Handoff en ATA

```yaml
handoffs:
  - label: "Ejecutar con EAA"
    agent: EAA
    prompt: "Ejecutá la suite de tests generada en esta sesión."
    send: false
  - label: "Analizar fallos con ROA"
    agent: ROA
    prompt: "Analizá las causas raíz de los fallos del último reporte."
    send: false
```

---

## Custom Agents en ATA: ORCA, TGA, EAA y ROA

Los cuatro agentes del framework ATA están implementados como Custom Agents en `.github/agents/`:

| Archivo | Agente | Rol |
|---------|--------|-----|
| `orca.agent.md` | Orchestrator Agent | Orquesta el CCV completo (TGA → EAA → ROA condicional) en una única sesión |
| `tga.agent.md` | Test Generation Agent | Diseña y genera casos de prueba ejecutables |
| `eaa.agent.md` | Execution & Analysis Agent | Ejecuta suites y produce reportes JSON normalizados |
| `roa.agent.md` | Root-cause & Optimization Agent | Diagnostica causas raíz y genera recomendaciones |
| `stack-setup.agent.md` | ATA Stack Setup | Configura STACK.yml de forma conversacional |

Todos comparten las siguientes convenciones:

- Frontmatter declara `tools` con el conjunto mínimo necesario (principio de mínimo privilegio).
- ORCA, TGA, EAA y ROA incluyen `hooks.SessionStart` apuntando a `require-stack.ps1/.sh` (bloquea si STACK.yml no está configurado).
- `stack-setup.agent.md` **no** tiene hook bloqueante para poder operar cuando STACK.yml está vacío.

El flujo completo de activación —desde el hook bloqueante hasta la carga de la skill— está documentado en [hooks.md](hooks.md) y [skills.md](skills.md).

---

## Consideraciones de seguridad

- **Principio de mínimo privilegio**: declará en `tools` solo las herramientas que el agente necesita. Un agente de planificación de solo lectura (`read_file`, `grep_search`) no debe tener `create_file` ni acceso a terminales.
- **Revisión de agentes compartidos**: antes de usar un `.agent.md` de un repositorio externo, revisá su lista de tools e instrucciones. Un agente malicioso podría incluir instrucciones para exfiltrar datos o ejecutar comandos destructivos.
- **user-invocable vs disable-model-invocation**: usá `user-invocable: false` para agentes auxiliares que no deben mostrarse en el dropdown pero sí ser invocados por otros agentes; usá `disable-model-invocation: true` para agentes que solo deben activarse manualmente.
- **Agentes de organización**: habilitar `github.copilot.chat.organizationCustomAgents.enabled: true` expone agentes definidos a nivel organizacional. Verificá que solo los agentes aprobados estén disponibles.
