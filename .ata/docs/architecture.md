# Arquitectura ATA

## Agentes Especializados

Cada agente es una **sesión efímera** de Copilot con identidad, herramientas y responsabilidades
acotadas. Se activan desde el selector de agentes del chat o escribiendo el prefijo correspondiente.

| Agente | Prefijo / Activación | Patrón interno | Responsabilidad |
|--------|---------------------|----------------|------------------|
| **ATA Stack Setup** | Selector de agentes / hook automático | Entrevista conversacional + Bootstrap | Configura `STACK.yml` y crea skills obligatorias por herramienta |
| **ORCA** | `/ORC` | Sequential + Bifurcación condicional | Orquesta el CCV completo (TGA → EAA → ROA condicional) en una única sesión |
| **TGA** | `/TGA` | Reflection (Generator-Critic) | Transforma requisitos en artefactos de prueba ejecutables |
| **EAA** | `/EAA` | Parallel Fan-Out + Synthesis | Ejecuta suites en múltiples entornos y produce reportes normalizados |
| **ROA** | `/ROA` | Reflexive Metacognitive + Ensemble | Diagnostica causas raíz y emite recomendaciones accionables |

### Jerarquía de control (aporte ATA)

En ATA, `ATA Stack Setup` y `ORCA` son la capa jerárquica superior: el primero habilita stack + skills,
y el segundo gobierna la ejecución CCV end-to-end.

```mermaid
flowchart TD
    SSU["ATA Stack Setup
    Bootstrap de Stack + Skills"] --> ORCA["ORCA
    Orquestación CCV"]
    ORCA --> TGA["TGA
    Generación"]
    ORCA --> EAA["EAA
    Ejecución"]
    ORCA --> ROA["ROA
    Optimización"]
```

### Resolución de herramientas por agente

Las herramientas concretas se resuelven en tiempo de ejecución desde `STACK.yml`. La tabla siguiente muestra **qué sección de STACK.yml** consume cada agente:

| Sección de STACK.yml | Stack Setup | ORCA | TGA | EAA | ROA |
|---------------------|:-----------:|:----:|:---:|:---:|:---:|
| `tga_skills.*` (unit, bdd, e2e, performance, ai_assisted) | ✓ | ✓ | ✓ | — | — |
| `tga_skills.*.skill_file` | ✓ | ✓ | ✓ | — | — |
| `eaa_skills.test_runner` + `browser_targets` | — | ✓ | — | ✓ | — |
| `eaa_skills.coverage_reporter` + `performance_runner` | — | ✓ | — | ✓ | — |
| `roa_skills.static_analysis` + `code_review_ai` | — | ✓ | — | — | ✓ |
| `roa_skills.defect_tracking` + `log_analysis` | — | ✓ | — | — | ✓ |
| `container_skills.*` + `skill_file` | ✓ | ✓ | — | ✓ | — |

---

## Ciclo Cerrado de Validación (CCV)

El flujo de trabajo sigue una secuencia unidireccional con retorno controlado:

```mermaid
flowchart TD
    SSU["@ATA Stack Setup
    Stack + Skills"] --> TGA
    TGA["/TGA — Genera artefactos"] -->|handoff-tga-id.json| EAA
    EAA["/EAA — Ejecuta y reporta"] -->|report-id.json| ROA
    ROA["/ROA — Diagnostica"] -->|rca-id.md| D{¿Fallos?}
    D -->|Sin fallos| OK([Ciclo completado])
    D -->|Con fallos — regenerar| TGA
    D -->|Con fallos — re-ejecutar| EAA
```

Cada transferencia entre agentes se realiza mediante un **manifiesto de handoff JSON** depositado en `/reports/execution/`. 
Ningún agente puede asumir el resultado de una sesión anterior sin que dicho artefacto esté presente en el contexto.

**Límite de convergencia:** el CCV se detiene automáticamente tras 5 ciclos sin reducción de fallos y escala el historial completo al equipo de desarrollo.

### ORCA: modo orquestado (CCV automático)

El agente **ORCA** (`/ORC`) ejecuta todo el diagrama anterior en una única sesión sin intervención del usuario entre fases. La bifurcación hacia ROA es **condicional**: solo se activa si EAA reportó `failed > 0` o `flaky > 0`.

Esta implementación explicita como capa de control superior a `ATA Stack Setup` + `ORCA`,
considerado el aporte distintivo del proyecto respecto a la arquitectura base del paper de referencia.

```mermaid
flowchart TD
    START(["Requisito recibido"]) --> SSU
    SSU["ATA Stack Setup
    valida stack + skills"] --> TGA
    TGA["Fase 1 — TGA
    Genera artefactos"] --> EAA
    EAA["Fase 2 — EAA
    Ejecuta y reporta"] --> BIF{"¿failed > 0
    o flaky > 0?"}
    BIF -->|No| OK(["CCV completado ✓"])
    BIF -->|Sí| ROA
    ROA["Fase 3 — ROA
    Diagnostica"] --> DEC{"Action
    Required"}
    DEC -->|TGA| LOOP["¿Ciclo < max_iterations?"]
    DEC -->|EAA| EAA
    DEC -->|HUMAN_REVIEW| ESC(["Escalar a humano"])
    DEC -->|NONE| OK2(["CCV completado con recomendaciones"])
    LOOP -->|Sí| TGA
    LOOP -->|No| ESC
```

> Para invocar ORCA: `/ORC <descripción del requisito o suite a validar>`

---

## Patrones Arquitectónicos Implementados

La suite combina patrones de los tres marcos de referencia principales en arquitecturas agénticas:

| Patrón | Aplicación en ATA |
|--------|-------------------|
| **Sequential + Bifurcación condicional** | Orquestación ORCA: TGA → EAA → ROA solo si hay fallos |
| **Sequential** | Flujo manual TGA → EAA → ROA (orden fijo, salida es input del siguiente) |
| **Parallel Fan-Out + Synthesis** | EAA ejecuta en chromium / firefox / webkit simultáneamente |
| **Reflection (Generator-Critic)** | TGA auto-valida cobertura ≥ 80 % antes de entregar artefactos |
| **Iterative Refinement** | Loop interno de TGA: máx. 3 iteraciones con condición de salida explícita |
| **Reflexive Metacognitive** | ROA escala a humano cuando la confianza del diagnóstico es < 50 % |
| **Ensemble** | ROA genera hipótesis paralelas H1/H2 cuando el delta de confianza es < 20 % |
| **Human-in-the-Loop + Dry-Run** | Operaciones destructivas requieren aprobación explícita antes de ejecutar |
| **Skills: Progressive Disclosure** | Los Skill Agents (Nivel 2) se cargan solo bajo demanda para evitar acumulación de tokens |

> Ver fuentes en [.ata/docs/references.md](references.md).
