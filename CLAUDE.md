# Ygg — RPG em primeira pessoa com física sistêmica e magia

Projeto único (não multi-projeto). O jogo vive na raiz desta pasta.

## Projeto

- **Engine**: Godot 4.7.2 (executável em `Godot_v4.7.2-stable_win64.exe/`)
- **Linguagem**: GDScript com tipagem estática
- **Física**: Jolt Physics (definido em `project.godot`)
- **Plataforma alvo**: PC (Windows), 60 fps
- **studio_mode**: `indie` (sem camada F2P; ignore agentes de monetização/UA salvo pedido explícito)
- **Conceito-chave**: física realista interagindo com magia. Tudo no mundo é um material
  com propriedades (massa, inflamável, explosivo...) e magias/habilidades são forças e
  estados aplicados a essa física. Ver `design/gdd/game-concept.md` e
  `design/gdd/physics-magic-system.md`.

## Sobre o usuário (Liam)

- Pouca experiência com programação: explique decisões técnicas em português simples,
  com passo a passo no editor do Godot quando ele precisar mexer em algo.
- Forte em **UX e QA**: envolva-o em decisões de interface, feedback ao jogador,
  critérios de aceite e roteiros de teste. Relatórios de bug seguem `/bug-report`.
- Responder sempre em **português do Brasil**.

## Elenco principal de agentes para o Ygg

Todos os 58 agentes do GameStudio60 estão em `.claude/agents/`. Para este projeto, os
mais relevantes são:

| Área | Agentes |
|------|---------|
| Direção | `creative-director`, `technical-director`, `producer` |
| Design | `game-designer`, `systems-designer` (física/magia), `level-designer`, `world-builder` |
| Programação | `lead-programmer`, `gameplay-programmer`, `godot-specialist`, `godot-gdscript-specialist`, `godot-shader-specialist`, `ai-programmer`, `prototyper` |
| UX/UI | `ux-designer`, `ui-programmer`, `accessibility-specialist` |
| Arte/Áudio | `art-director`, `technical-artist`, `sound-designer` |
| Qualidade | `qa-lead`, `qa-tester`, `performance-analyst` |

Fluxos coordenados úteis: `/start`, `/brainstorm`, `/prototype`, `/team-combat`,
`/team-ui`, `/team-level`, `/playtest-report`, `/bug-report`, `/sprint-plan`.

## Estrutura

```text
/
├── project.godot            # Configuração do Godot
├── src/
│   ├── core/                # Autoloads: Settings, GameState, InputBindings
│   ├── ui/                  # Menus (principal, classes, configurações, pausa) e HUD
│   ├── gameplay/
│   │   ├── player/          # Controle em primeira pessoa e dados de classe
│   │   ├── abilities/       # Habilidades (Resource com lógica de ativação)
│   │   ├── world/           # Props físicos, materiais, explosões
│   │   └── fx/              # Efeitos visuais gerados por código
│   └── levels/              # Arena de testes
├── assets/
│   ├── data/                # .tres de classes e materiais (valores de gameplay)
│   └── ui/                  # Tema da interface
├── design/gdd/              # Documentos de design
├── tests/                   # Teste de fumaça automatizado
└── production/              # Sprints, logs de sessão
```

## Regras de código

- Valores de gameplay ficam em `.tres` em `assets/data/`, nunca soltos no código.
- Ações do jogador são processadas em `_physics_process` (consultas de física seguras).
- Sistemas se comunicam por sinais; gameplay não referencia UI diretamente.
- Antes de entregar mudança em código, rode o teste de fumaça (ver `tests/README.md`).

## Protocolo de colaboração

Pergunta → Opções → Decisão → Rascunho → Aprovação. Sem commits sem pedido do usuário.

## Coordenação e padrões

@.claude/docs/coordination-rules.md

@.claude/docs/coding-standards.md

@.claude/docs/context-management.md
