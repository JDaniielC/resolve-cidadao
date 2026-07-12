# Resolve Cidadão 🏘️

<img src="https://img.shields.io/badge/Godot_4.6-blue?logo=godotengine&logoColor=white" alt="Godot 4.6">
<img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">

Jogo educacional narrativo (top-down 2D) sobre acesso a direitos sociais durante enchentes
urbanas no Recife. O jogador é um cidadão comum: explora ruas alagadas, conversa com
vizinhos, usa o celular para descobrir quais órgãos procurar, e toma decisões cujas
consequências aparecem no medidor de satisfação da cidade.

Feito em **Godot 4.6**, exporta para **web** e é publicado no GitHub Pages a cada push na
`main`.

## 🎯 Objetivo pedagógico

Ensinar, na prática e sem sermão:

- **Direitos do cidadão** durante desastres naturais
- **Órgãos públicos reais** e suas funções — Defesa Civil, COMPESA, Assistência Social
- **Programas sociais reais** — aluguel social, abrigos de emergência
- Que informação clara é, ela mesma, um direito

O tom é leve e esperançoso, não denuncista. Não há game-over punitivo.

## 📖 Missões

**Missão 01 — "A Chuva Não Para"** (tutorial). Apresenta movimento, diálogo com escolhas,
o celular, o mapa, a passagem de tempo e o pós-enchente. NPC central: Dona Maria.

**Missão 02 — "Teimosia que Salva"**. NPCs Lucas e Seu Severino. Fluxo em
`scripts/mission_02_flow.gd`, diálogos em `dialogues/missao_02/`.

Roteiro completo em [`roteiro.md`](roteiro.md); os GDDs por missão em
[`plan_1.md`](plan_1.md) e [`plan_2.md`](plan_2.md).

## 🎮 Sistemas

| Sistema | Onde |
| --- | --- |
| **Diálogo** — conversas e escolhas que afetam a narrativa | `scripts/systems/dialogue_system.gd` + addon Dialogue Manager |
| **Celular** — órgãos públicos, mapa, base de conhecimento | `scripts/ui/phone_menu.gd`, `scenes/ui/phone_menu.tscn` |
| **Satisfação da cidade** — medidor que reflete as decisões | `scripts/autoloads/` (GameManager) |
| **Clima e tempo** — chuva, alagamento, ciclo dia/noite | `scripts/systems/weather_controller.gd`, `screen_rain.gd`, `day_night_controller.gd` |
| **Missão** — progresso, objetivos, avaliação final | `scripts/ui/mission_*`, `scripts/mission_02_flow.gd` |
| **Save** | `scripts/SaveFileManager.gd`, `scripts/user_prefs.gd` — arquivo local, sem banco |

**Mobile:** há joystick virtual (`scripts/ui/virtual_joystick.gd`) e a orientação do projeto
é retrato.

**Idiomas:** pt-BR (base), en e it — `local/translations.csv`.

## 🏗️ Estrutura

```
scenes/
├── main_game.tscn
├── levels/           rain_street, rain_street_ray, shelter, destructed_street, Level (template)
├── npcs/             dona_maria, lucas, seu_severino, agente_social, assistente
├── ui/               phone_menu, hud, choice_panel, dialogue_box
│   └── menus/        main_menu, pause, credits, mission_complete, mission_assessment
└── props/  system/
scripts/
├── autoloads/        Globals, GameManager, SceneManager, DataManager, Notifications, Popups
├── systems/          dialogue_system, weather_controller, day_night_controller, screen_rain
├── ui/               phone_menu, hud, pause_menu, virtual_joystick, mission_*
└── state_machine/  characters/  checks/  data/
dialogues/            missao_01/, missao_02/, agente_social, commons, start; balloons/
entities/             prefabs reutilizáveis: player/, npcs/, animations/, hit_box, hurt_box
components/           inventory, jumper, transfer, target_manager
assets/               sprites/, ui/, fonts/, sfx/, effects/, shaders/
tilesets/             abrigo, bairro-1, casas-1/2, pos-enchente, city_asset
local/                translations.csv
```

## 🚀 Rodar

Requisitos: **Godot 4.6** (CI usa 4.6.3), renderer **GL Compatibility**.

1. Clone o repositório
2. Abra a pasta no Godot 4.6
3. F5

A cena inicial é `scenes/ui/menus/main_menu.tscn` (definida em `project.godot`), **não**
`main_game.tscn`.

### Build web

```bash
godot --headless --path . --export-release "Web" dist/web/index.html
```

É o comando que a CI roda. `.github/workflows/deploy-web.yml` publica no GitHub Pages a
cada push na `main`, e corta um release zipado nas tags `v*`.

## 🎨 Estilo

Top-down 2D, pixel art, viewport 1280x720. Ambientação realista do Recife — os tilesets são
de bairro alagado, casas e abrigo.

## 🛠️ Base técnica

Fork do **Godot 2D Top-Down Template** de Stefano Mercadante (máquina de estados, áreas de
interação, gerenciador de cenas). Addons: **Godot Dialogue Manager** (nathanhoad) e
**Tile Bit Tools** (dandeliondino).

Só GDScript — sem C#/.NET.

## 📌 Estado

Duas missões jogáveis. Versionamento drifou: `project.godot` ainda diz `1.9.1` e o
`CHANGELOG.md` para em 2025-05-25, apesar de um ano de commits desde então.

Documentação interna (`CLAUDE.md`, `DEVELOPMENT.md`) também está desatualizada em pontos —
descreve o celular e o clima como não implementados, e uma árvore de diretórios
(`assets/recife/`, `assets/characters/`, `scenes/levels/missao_01/`) que não existe. Confie
neste README e no código.

## 🤝 Contribuir

Fluxo por PR. Abra uma issue descrevendo a ideia, faça fork, branch, PR.

Commits: `feat:`, `fix:`, `docs:`, `refactor:`.

## 🙏 Créditos

- **Godot Engine**
- **Godot Dialogue Manager** — nathanhoad
- **Godot 2D Top-Down Template** — Stefano Mercadante
- **Tile Bit Tools** — dandeliondino

**Autor:** José Daniel Silva do Carmo · **Licença:** MIT
