# Guia de Desenvolvimento - Resolve Cidadão

## 🛠️ Setup do Ambiente

### Requisitos
- **Godot 4.4+** (testado em 4.6.1)
- Sistema operacional: Windows, macOS ou Linux
- Git para controle de versão

### Instalação Rápida
1. Instale [Godot 4.6.1](https://godotengine.org/download)
2. Clone o repositório:
   ```bash
   git clone <repo-url>
   cd resolve-cidadao
   ```
3. Abra a pasta no Godot Editor
4. Aguarde importação de assets
5. Pressione F5 para rodar

## 📂 Estrutura de Desenvolvimento

### Convenção de Pastas

```
scenes/
├── levels/           # Missões principais
├── menus/           # Telas de menu
├── npcs/            # Personagens definidos
├── props/           # Objetos interativos
├── system/          # Cenas de sistema
└── ui/              # Componentes de UI

scripts/
├── autoloads/       # Singletons globais
├── characters/      # Lógica de personagens
├── checks/          # Validações
├── systems/         # Sistemas principais (diálogo, celular, etc)
├── state_machine/   # Sistema de estados
├── ui/              # Scripts de UI
└── utils/           # Funções utilitárias

dialogues/           # Arquivos de diálogo (.dialogue)
entities/            # NPCs, inimigos, base de caracteres
assets/              # Arte, spritesheets
tilesets/           # Definições de tilemap
```

## 🎯 Fluxo de Trabalho

### Adicionar uma Nova Missão

1. **Criar cena de nível:**
   - Duplicar `scenes/levels/Level.tscn`
   - Renomear para `missao_X.tscn`
   - Configurar tilemap e objetos

2. **Adicionar NPCs:**
   - Instanciar prefabs de personagens em `entities/npcs/`
   - Configurar posição e estado inicial

3. **Criar diálogos:**
   - Adicionar arquivo `.dialogue` em `dialogues/`
   - Usar Dialogue Manager UI (dentro do Godot)

4. **Conectar à progressão:**
   - Registrar em `scripts/systems/dialogue_system.gd`
   - Adicionar à lista de missões em `scripts/autoloads/GameManager.gd`

### Adicionar um Novo NPC

1. **Criar script:**
   - Herdar de `entities/character_entity.gd`
   - Definir sprites, animações, comportamento

2. **Criar cena:**
   - `entities/npcs/nome_npc.tscn`
   - Adicionar sprite, collision, dialogue trigger

3. **Adicionar diálogos:**
   - Criar arquivo em `dialogues/nome_npc_data.gd` (ou `.dialogue`)

### Modificar UI

- Scripts de UI estão em `scripts/ui/`
- Cenas em `scenes/ui/`
- HUD principal: `scripts/ui/hud.gd`
- Diálogo: `scripts/ui/dialogue_box.gd`
- Painel de escolhas: `scripts/ui/choice_panel.gd`

## 🧪 Testando

### Teste Rápido
```
F5 (ou Play button)
```

### Teste de Cena Específica
1. Clique direito na cena em FileSystem
2. "Play from Here"

### Debug
- Use `print()` para logs no console
- Abra Debug > Debugger para breakpoints
- `@onready` usa validação em tempo de execução

## 💾 Sistema de Diálogos

### Editar Diálogos (Dialogue Manager)

1. Abra o painel "Dialogue Manager" (aba)
2. Clique no arquivo `.dialogue` desejado
3. Editor visual apresenta:
   - Nós de fala (texto)
   - Escolhas (branches)
   - Condições
   - Sinais (triggers)

### Estrutura de Diálogo

```
título_diálogo:
	speaker: Dona Maria
	Fala da personagem aqui...
	- [opção 1] -> próximo_nó
	- [opção 2] -> outro_nó
```

### Integração com Código

```gdscript
# Iniciar diálogo
DialogueManager.show_dialogue_balloon(dialogue_resource, "título_diálogo")

# Esperar término
await DialogueManager.dialogue_ended
```

## 🎨 Assets e Artes

### Padrões de Sprite
- **Size:** 32x32 pixels (base)
- **Formato:** PNG com transparência
- **Proporção:** Mantém pixel art consistente

### Hierarquia de Camadas
```
Player
├── Sprite2D
├── CollisionShape2D
├── InteractionArea
└── AnimationPlayer

NPC
├── Sprite2D
├── CollisionShape2D
├── DialogueTrigger
└── AnimationPlayer
```

## 🔊 Áudio

### Música
- Localização: `assets/music/`
- Formato: .ogg (comprimido)
- Player: `AudioStreamPlayer` (global)

### Efeitos
- Localização: `assets/sfx/`
- Carregamento: `AudioStreamPlayer2D` (posicional)

## ✅ Checklist Pré-Commit

Antes de fazer commit:

- [ ] Código compila sem erros
- [ ] Nenhum `print()` de debug deixado
- [ ] Cenas testadas em play
- [ ] Scripts seguem convenção GDScript
- [ ] Mensagem de commit é descritiva

## 📝 Convenções de Código

### GDScript
```gdscript
# Classes e enums usam PascalCase
class_name PlayerController

# Funções/variáveis usam snake_case
func move_player():
	pass

# Constantes usam UPPER_SNAKE_CASE
const SPEED_MULTIPLIER = 2.0

# Variáveis privadas com _
var _internal_state: int

# Tipos sempre definidos
func calculate_damage(base: int, modifier: float) -> int:
	return int(base * modifier)
```

### Organização de Arquivos
- 1 classe por arquivo
- Nome do arquivo = nome da classe (snake_case)
- Imports no topo

## 🐛 Debugging

### Problemas Comuns

**NPC não responde a interação:**
- Verificar se `InteractionArea` está configurado
- Validar signal `on_interaction` conectado
- Confirmar `process_mode` não está pausado

**Diálogo não aparece:**
- Verificar resource path do arquivo `.dialogue`
- Confirmar formato correto em `DialogueManager.show_dialogue_balloon()`
- Checar console por erros

**Animações faltam:**
- Validar `AnimationPlayer` existe na cena
- Confirmar nomes de animação em código
- Usar `AnimationPlayer.play()` com nome correto

## 🚀 Build e Deploy

### Exportar para Web
1. Project > Export
2. Selecionar "Web" (HTML5)
3. Configurar paths
4. Export Project

### Performance
- Limite de 60 FPS padrão
- Otimize tilesets com atlases
- Use `VisibleOnScreenNotifier2D` para culling

## 📚 Recursos Úteis

- [Documentação Godot 4](https://docs.godotengine.org/)
- [Dialogue Manager Docs](https://github.com/nathanhoad/godot_dialogue_manager)
- [GDScript Best Practices](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/index.html)

## 🤝 Contribuindo

1. Crie branch: `feature/sua-feature`
2. Faça commits descritivos
3. Teste antes de abrir PR
4. Descreva mudanças no PR

---

**Dúvidas?** Abra uma issue ou entre em contato!
