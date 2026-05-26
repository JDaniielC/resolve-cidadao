# Resolve Cidadão 🏘️

<img src="https://img.shields.io/badge/Godot_4.6+-blue?logo=godotengine&logoColor=white" alt="Godot 4.6+">
<img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">

Um jogo educacional que simula decisões cívicas e direitos sociais em contextos de desastres naturais. Desenvolvido em Godot 4, **Resolve Cidadão** busca ensinar à população urbana como acessar seus direitos e serviços públicos durante crises.

## 🎮 Sobre o Jogo

**Resolve Cidadão** é um jogo narrativo em perspectiva top-down inspirado em simuladores sociais. O jogador assume o papel de um cidadão durante eventos climáticos extremos (enchentes, alagamentos) na cidade do Recife e deve descobrir:

- Como acessar direitos sociais e benefícios públicos
- Quais órgãos procurar em situações de emergência
- Consequências de decisões cívicas
- A importância da informação e engajamento comunitário

### 🎯 Objetivo Pedagógico

Ensinar de forma leve e interativa sobre:
- **Direitos do cidadão** durante desastres naturais
- **Órgãos públicos** e suas funções (Defesa Civil, Prefeitura, Assistência Social)
- **Políticas de proteção social** (aluguel social, abrigos de emergência)
- **Impacto comunitário** e consequências sociais

## 📖 Primeira Missão: "A Chuva Não Para"

A missão inicial é um tutorial que apresenta os principais sistemas do jogo:

### Etapas
1. **Controles básicos** - Movimento em rua alagada
2. **Primeiro NPC** - Encontro com Dona Maria
3. **Identificar necessidade** - Responder onde procurar ajuda
4. **Desbloqueio do celular** - Sistema de menu e informações
5. **Mapa e navegação** - Encontrar abrigo temporário
6. **Passagem de tempo** - Clima muda, água baixa
7. **Pós-enchente** - Lidar com consequências
8. **Descobrir direito** - Qual programa ajuda?
9. **Acesso a informações** - Como funciona aluguel social
10. **Conclusão** - Satisfação aumenta, player aprende

### Mecânicas Apresentadas
- Movimento e interação
- Diálogos e escolhas múltiplas
- Sistema de celular/menu
- Navegação por mapa
- Sistema de satisfação da cidade
- Feedback educacional

## 🎮 Sistemas Principais

### **Sistema de Diálogo**
- Conversas com NPCs
- Escolhas que afetam a narrativa
- Banco de dados de diálogos estruturado

### **Sistema de Celular**
- Registro de problemas na cidade
- Contatos de órgãos públicos
- Mapa interativo
- Base de conhecimento (conceitos desbloqueáveis)

### **Sistema de Satisfação**
- Medidor que reflete qualidade de vida na cidade
- Aumenta com boas decisões
- Afeta desbloqueio de conteúdo

### **Sistema de Tempo**
- Ciclo dia/noite
- Eventos climáticos (chuva, enchentes)
- Passagem de etapas narrativas

## 🎨 Estilo Visual

- **Perspectiva:** Top-down 2D
- **Estilo:** Pixel art/sprites handcrafted
- **Localização:** Recife (bairros como Coque, Brasília Teimosa)
- **Tempo visual:** Contexto realista de enchentes urbanas

## 🏗️ Estrutura do Projeto

```tree
resolve-cidadao/
├── scenes/              # Cenas do jogo
│   ├── levels/         # Missões e níveis
│   ├── npcs/           # Personagens não-jogáveis
│   ├── ui/             # Interface do usuário
│   └── menus/          # Menus (start, settings)
├── scripts/            # Lógica do jogo
│   ├── characters/     # Scripts de personagens
│   ├── systems/        # Sistemas principais
│   ├── ui/             # Scripts de UI
│   └── autoloads/      # Managers globais
├── dialogues/          # Banco de diálogos
├── entities/           # NPCs, inimigos, props
├── assets/             # Arte e recursos
├── tilesets/           # Tilesets para mapas
└── particles/          # Efeitos de partículas
```

## 🚀 Começar a Jogar

### Requisitos
- Godot 4.4 ou superior (testado em 4.6.1)
- Compatibilidade com GL

### Instruções
1. Clone o repositório
2. Abra o projeto em Godot 4.6+
3. Pressione Play (F5) ou use o botão Run
4. A cena inicial é `main_game.tscn`

### Configuração
- Adapte `project.godot` conforme necessário
- Configure o nível inicial em `start_screen.tscn`
- Diálogos estão em `dialogues/` (formato compatível com Dialogue Manager)

## 📋 Features Implementadas

- ✅ Sistema de movimento e controles
- ✅ Sistema de diálogo com múltiplas escolhas
- ✅ HUD com objetivos e satisfação
- ✅ Panel de escolhas
- ✅ Interação com NPCs (proximidade)
- ✅ Cenas de nível estruturadas
- ✅ Animações básicas

## 🔧 Em Desenvolvimento

- UI do celular (mapa, órgãos públicos)
- Sistema completo de missões
- Mais NPCs e diálogos
- Efeitos de clima e partículas
- Sistema de satisfação funcional
- Fase pós-enchente

## 👨‍💻 Desenvolvimento

**Autor:** José Daniel Silva do Carmo  
**Licença:** MIT  
**Engine:** Godot 4.6+  
**Linguagem:** GDScript  

## 🤝 Contribuições

Contribuições são bem-vindas! Se encontrar bugs, tiver sugestões de features educacionais ou quiser contribuir com arte/narrativa:

1. Abra uma issue descrevendo a sugestão
2. Faça fork e crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch e abra um Pull Request

## 📚 Recursos Pedagógicos

Este jogo foi desenvolvido com foco em educação cidadã. Conceitos abordados:

- Direitos constitucionais em situações de emergência
- Acessibilidade a políticas sociais
- Importância de informação clara para cidadãos
- Responsabilidades do poder público
- Solidariedade comunitária

## 🙏 Créditos

- **Godot Engine** - Engine
- **Godot Dialogue Manager** by nathanhoad - Sistema de diálogos
- **Godot 2D Top-Down Template** by Stefano Mercadante - Base arquitetural
- **Tile Bit Tools** by dandeliondino - Ferramentas de tilemap

## 📝 Notas

Este é um projeto em desenvolvimento ativo. A visão é criar uma série de missões educacionais que cobrem diferentes temas de cidadania e direitos sociais.

---

**Sugestões, críticas e feedback são muito bem-vindos!**
