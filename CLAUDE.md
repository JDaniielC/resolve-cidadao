# Resolve Cidadão - Documentação Interna

**Desenvolvedor:** José Daniel Silva do Carmo  
**Engine:** Godot 4.6+  
**Tipo:** Jogo educacional narrativo (top-down 2D)  
**Data de Início:** 2025-05-25  

## 🎮 Visão do Projeto

Um jogo que simula situações reais de acesso a direitos sociais e serviços públicos durante crises urbanas (enchentes, alagamentos). Foco pedagógico em educação cidadã, especialmente para população do Recife.

## 📖 Narrativa Central

**Contexto:** Enchentes urbanas no Recife  
**Protagonista:** Cidadão comum (jogador)  
**NPCs principais:**
- **Dona Maria** - Personagem tutorial, moradora afetada por enchente
- Funcionários de abrigo
- Agentes da Defesa Civil
- Assistentes sociais

**Loop Principal:**
1. Explorar cenário
2. Conversar com NPCs
3. Entender problemas/necessidades
4. Usar celular para descobrir recursos
5. Tomar decisão/encontrar solução
6. Ver consequência educacional

## 🎯 Objetivos por Fase

### Phase 1: Tutorial "A Chuva Não Para" (Em Desenvolvimento)
- ✅ Mecânicas básicas (movimento, interação)
- ✅ Sistema de diálogo com escolhas
- ✅ HUD com objetivos
- 🔄 UI do celular (mapa, órgãos públicos)
- 📋 Sequência completa Dona Maria
- 📋 Sistema de satisfação funcional

### Phase 2: Próximas Missões (Planejadas)
- Buscador de direitos específicos
- Mais NPCs e histórias
- Múltiplos finais baseados em escolhas

## 🏗️ Arquitetura Técnica

### Sistemas Implementados
- **DialogueSystem** - Gerencia fluxo de diálogos e escolhas
- **GameManager** - Estado global do jogo, missões
- **SceneManager** - Transições entre cenas
- **HUD** - Objetivos e satisfação visível

### Sistemas em Progresso
- **PhoneMenu** - Celular com mapa, órgãos, educação
- **MissionSystem** - Rastreamento de progresso
- **SatisfactionSystem** - Impacto das decisões

### Convenções

**Nomes de Scripts:**
- CamelCase para classes: `PlayerController`, `DialogueSystem`
- snake_case para métodos/variáveis: `move_player()`, `current_health`
- UPPER_SNAKE_CASE para constantes: `SPEED_MULTIPLIER`

**Organização de Cenas:**
- 1 scene = 1 localização/nível
- Prefabs em `entities/` para reutilização
- UI em `scenes/ui/`

**Diálogos:**
- Arquivo `.dialogue` por NPC ou localização
- Estrutura em `dialogues/missão_XX/`
- Balloon em `dialogues/balloons/`

## 📂 Estrutura de Ficheiros Esperada

```
scenes/levels/
├── Level.tscn           # Template base
└── missao_01/
	├── rain_street.tscn
	└── shelter.tscn

dialogues/
├── missao_01/
│   ├── dona_maria.dialogue
│   ├── shelter_workers.dialogue
│   └── civil_defense.dialogue
└── balloons/

assets/
├── recife/              # Backgrounds de Recife
├── characters/
│   ├── player/
│   ├── dona_maria/
│   └── npcs/
├── ui/
├── effects/             # Chuva, água, etc
└── music/
```

## 🎨 Decisões de Design

### Visual Style
- Pixel art 32x32 (base)
- Inspiração em Stardew Valley / Pellet Town
- Paleta tropical realista (Recife)
- Top-down isométrico falso

### Gameplay
- Foco narrativo > ação
- Educação através de escolhas
- Múltiplos caminhos/finais
- Sem perda ou game-over punitivo

### Educação
- Conceitos apresentados gradualmente
- Referências a órgãos REAIS (Defesa Civil, COMPESA, etc)
- Programas sociais verificados (aluguel social, abrigos)
- Tom leve/esperançoso, não deprimente

## 🐛 Conhecidos/Issues

### Em Desenvolvimento
- [ ] UI do celular (phone_menu.gd criado, não conectado)
- [ ] Sistema de satisfação não afeta gameplay ainda
- [ ] Mapa não é funcional
- [ ] Transição climática visual falta

### Para Revisar
- Animations: Dona Maria falta algumas expressões
- Performance: Verificar se rain particles otimizadas

## 🚀 Próximos Passos (Prioridade)

1. **Completar UI do Celular**
   - Conectar phone_menu.gd à HUD
   - Implementar mapa funcional
   - Listar órgãos públicos com descrições

2. **Finalizar Diálogos Missão 01**
   - Expandir conversa Dona Maria
   - Adicionar mais NPCs no abrigo
   - Implementar consequências das escolhas

3. **Melhorar Assets Visuais**
   - Substituir rua alagada genérica
   - Criar backgrounds do Recife
   - Animar chuva/água

4. **Sistema de Missão**
   - Rastreamento de progresso
   - Objetivos atualizáveis
   - Desbloqueio de conteúdo

## 💾 Como Trabalhar Neste Projeto

### Adicionar Novo NPC
1. Criar sprite em `assets/characters/nome/`
2. Criar cena em `entities/npcs/nome_npc.tscn`
3. Criar diálogo em `dialogues/missao_XX/nome_npc.dialogue`
4. Herdar de `CharacterEntity`
5. Conectar trigger de interação

### Adicionar Novo Diálogo
1. Criar arquivo em `dialogues/missao_XX/novo_dialogo.dialogue`
2. Usar editor visual do Dialogue Manager
3. Testar com `DialogueManager.show_dialogue_balloon()`
4. Conectar a triggers/eventos

### Testar Missão
```gdscript
# Em scripts, iniciar dialogue
DialogueManager.show_dialogue_balloon(
	load("res://dialogues/missao_01/dona_maria.dialogue"),
    "start"
)
```

## 📚 Recursos de Referência

- [Stardew Valley](https://www.stardewvalley.net/) - Inspiração visual/gameplay
- [Roteiro.md](../roteiro.md) - Documento de design completo
- [Godot Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager)
- [Recife - Geografia/Realidade](https://pt.wikipedia.org/wiki/Recife)

## 🤝 Padrões de Colaboração

### Commits
```
feat: adicionar novo NPC
fix: corrigir diálogo que não aparecia
docs: atualizar README
refactor: reorganizar dialogue system
```

### Code Review Pontos
- Segue convenção de nomes?
- Tem tipos definidos?
- Testado em play?
- Sem `print()` de debug?

## 📝 Notas Importantes

- **NÃO remover** scripts de autoload sem revisar dependências
- **SEMPRE testar** novos diálogos no Dialogue Manager antes de commitar
- **Manter** compatibilidade com Godot 4.4+ (typed dictionaries)
- **Documentar** decisões não óbvias em código

---

**Última atualização:** 2025-05-25  
**Mantido por:** José Daniel Silva do Carmo
