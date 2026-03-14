# Referencias

Las siguientes fuentes fundamentaron el diseño de los patrones arquitectónicos, los flujos de
orquestación y los criterios de selección de agentes implementados en esta suite.

## Patrones de arquitecturas agénticas

**[1] Google Cloud Architecture Center** — *Elegir un patrón de diseño para tu sistema de IA con agentes* (2025)
Guía de referencia oficial de Google Cloud que clasifica los patrones de diseño de sistemas
agénticos (secuencial, paralelo, bucle, coordinador, jerárquico, enjambre, ReAct,
Human-in-the-Loop, lógica personalizada) con matrices de selección por tipo de flujo de trabajo.
Fundamentó la **Matriz de Selección de Patrones** del Orquestador Pasivo y los sub-patrones
aplicados en TGA (Iterative Refinement), EAA (Parallel) y ROA (ReAct + Human-in-the-Loop).
https://docs.cloud.google.com/architecture/choose-design-pattern-agentic-ai-system?hl=es

---

**[2] Joakim Vivas** — *17 Patrones de Arquitecturas Agénticas de IA*
Catálogo práctico de 17 patrones agénticos con énfasis en Progressive Disclosure (Skills),
Reflexive Metacognitive y Ensemble. Fundamentó la arquitectura de tres niveles
(Orchestrator → Domain Agent → Skill Agent) y las reglas de carga bajo demanda de skills
declaradas en `STACK.yml`.
https://www.joakimvivas.com/tech/17-patrones-arquitecturas-agenticas-ia/

---

**[3] LangChain Blog** — *Choosing the Right Multi-Agent Architecture*
Análisis comparativo de arquitecturas multi-agente con foco en el trade-off entre
patrones con y sin estado compartido, latencia de routing y eficiencia de tokens.
Fundamentó la tabla de sub-patrones de paralelismo (Router + Parallel vs. Sequential vs.
Subagents vs. Skills) y la regla de performance del Orquestador Pasivo (Regla 3).
https://blog.langchain.com/choosing-the-right-multi-agent-architecture/

---

## Investigación académica

**[4] Naqvi, S., Baqar, M., Mohammad, N. A.** — *The Rise of Agentic Testing: Multi-Agent Systems
for Robust Software Quality Assurance* (arXiv:2601.02454, enero 2026)
Paper que introduce un framework de testing multi-agente de bucle cerrado con TGA, EAA y ROA
como agentes nucleares — arquitectura directamente homóloga a la ATA. Reporta una reducción
del 60 % en tests inválidos y una mejora del 30 % en cobertura respecto a baselines de agente
único, mediante ejecución en sandbox, reporting de fallos detallado y regeneración iterativa.
Valida empíricamente el **Ciclo Cerrado de Validación (CCV)** implementado en esta suite.
https://arxiv.org/abs/2601.02454
