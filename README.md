# Arquitectura de Testing Agéntico (ATA)

Propuesta de arquitectura para construcción dinámica de sistema de pruebas de software basada en sesiones agénticas especializadas, efímeras y paralelizables. 
La implementación de referencia opera sobre **GitHub Copilot in Visual Studio Code**, pero la arquitectura es agnóstica respecto al motor de agentes: cualquier plataforma que soporte agentes LLM con instrucciones de sistema, herramientas y handoffs puede adoptar los mismos protocolos sin dependencia de ningún framework específico de construcción de agentes ni de testing.
Los agentes se invocan mediante prefijos de comando directamente desde el chat del editor y resuelven en tiempo de ejecución las herramientas declaradas por el desarrollador en `STACK.yml`.

ATA también puede declarar runtimes y orquestadores de contenedores en `STACK.yml`
(`container_skills`) para ejecutar suites en entornos Docker, Docker Compose, Podman o Kubernetes.

---

## Inicio rápido

```
# 1. Completar STACK.yml o activar el asistente de configuración
@ATA Stack Setup  ←  desde el selector de agentes del chat

# Opción A — Ciclo CCV completo automático (recomendado)
/ORC Como usuario registrado, quiero iniciar sesión con email y contraseña.

# Opción B — Flujo manual paso a paso (mayor control por fase)
# 2. Generar casos de prueba desde un requisito
/TGA Como usuario registrado, quiero iniciar sesión con email y contraseña.

# 3. Ejecutar los tests generados en múltiples navegadores
/EAA Ejecutar /tests/e2e/login.spec.ts en chromium, firefox y webkit.

# 4. Analizar los fallos del último reporte
/ROA Analizar /reports/execution/report-<session_id>.json

# Opción C — Ejecución en contenedores declarados en STACK.yml
/EAA Ejecutar /tests/e2e/login.spec.ts usando compose_orchestrator.
```

---

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [Primeros Pasos](.ata/docs/getting-started.md) | Configuración de `STACK.yml`, archivos del proyecto |
| [Custom Agents](.ata/docs/custom-agents.md) | Definición de agentes `.agent.md`, handoffs, seguridad |
| [Skills](.ata/docs/skills.md) | Carga progresiva de skills, `SKILL.md`, integración con STACK.yml |
| [Hooks](.ata/docs/hooks.md) | Ciclo de vida de hooks, arquitectura de dos capas, seguridad |
| [Arquitectura](.ata/docs/architecture.md) | Composición de la suite, agentes, CCV, patrones arquitectónicos |
| [Referencias](.ata/docs/references.md) | Fuentes académicas y técnicas que fundamentan el diseño |

---

## Estructura del repositorio

```
/
├── .github/                            ← Paths fijos por convención de VS Code / GitHub
│   ├── copilot-instructions.md         ← Orquestador Pasivo: reglas universales
│   ├── agents/                         ← Definiciones de agentes (path nativo VS Code)
│   │   ├── stack-setup.agent.md
│   │   ├── orca.agent.md               ← orquestador: CCV automático end-to-end
│   │   ├── tga.agent.md
│   │   ├── eaa.agent.md
│   │   └── roa.agent.md
│   └── hooks/
│       └── session-start.json          ← Hook SessionStart (advisory)
├── .ata/                               ← Componente ATA (tooling autocontenido)
│   ├── docs/                           ← Documentación del componente
│   │   ├── architecture.md
│   │   ├── getting-started.md
│   │   ├── custom-agents.md
│   │   ├── skills.md
│   │   ├── hooks.md
│   │   └── references.md
│   ├── AGENTS.md                       ← Protocolos completos de agentes
│   ├── stack.schema.json               ← JSON Schema para STACK.yml
│   ├── skills/                         ← Skills por herramienta (carga bajo demanda)
│   │   └── .gitkeep
│   └── hooks/                          ← Scripts ejecutados por los hooks
│       ├── validate-stack.ps1/.sh      ← Advisory (workspace)
│       └── require-stack.ps1/.sh      ← Bloqueante (agent-scoped en ORCA/TGA/EAA/ROA)
├── tests/                              ← Tests generados por TGA (rastreados en git)
│   ├── unit/.gitkeep
│   ├── e2e/.gitkeep
│   └── performance/.gitkeep
├── reports/                            ← Salida de EAA y ROA (ignorada en git)
│   ├── execution/.gitkeep
│   └── analysis/.gitkeep
├── .gitignore
└── STACK.yml                           ← Herramientas del proyecto (editar aquí)
```


---
## Importante - Uso Académico
>Proyecto desarrollado para la **Maestría en Tecnologías de la Información (UNNE/UNaM)** — Asignatura *"Pruebas de Software"*. 
Este sistema **NO ha sido arduamente evaluado ni garantiza, bajo ningún criterio, solidez en los resultados de las pruebas ni compatibilidad con cualquier herramienta de QA Automation**. Solo busca demostrar la capacidad de integración de tecnologías de agentes (puntualmente, en el chat de **GitHub Copilot in VS Code**). 
Las inferencias son generadas por modelos de IA y **no sustituyen las habilidades técnicas de un experto en calidad de software.**.
Siempre se recomienda aplicar este desarrollo bajo supervisión de un profesional experto en Calidad de Software, particularmente en el área de Pruebas de Software.
