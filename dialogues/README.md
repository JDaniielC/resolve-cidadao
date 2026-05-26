# Sistema de Diálogos - Resolve Cidadão

Documentação do sistema de diálogos e como criar/editar diálogos.

## 📁 Estrutura

```
dialogues/
├── missao_01/              # Diálogos da primeira missão
│   ├── dona_maria.dialogue
│   ├── shelter_workers.dialogue
│   └── civil_defense.dialogue
├── commons.dialogue        # Diálogos reutilizáveis
├── balloons/               # UI de apresentação de diálogos
│   └── dialogue_balloon.tscn
└── README.md               # Este arquivo
```

## 🎬 Editando Diálogos

### Abrir Editor de Diálogos

1. Abra Godot
2. Clique na aba **"Dialogue Manager"** (parte superior)
3. Selecione arquivo `.dialogue` no FileSystem
4. Editor visual aparecerá

### Criar Novo Diálogo

1. Em `dialogues/missao_01/`, crie arquivo novo: `novo_npc.dialogue`
2. Abre automaticamente no editor
3. Comece digitando:

```
start:
    speaker: Nome do NPC
    Primeira fala da conversa...
    - [Opção 1] -> segunda_parte
    - [Opção 2] -> outra_rota

segunda_parte:
    speaker: Nome do NPC
    Resposta à opção 1...

outra_rota:
    speaker: Nome do NPC
    Resposta à opção 2...
```

### Sintaxe Básica

#### Título do Nó
```
titulo_do_no:
```
- Começa linha
- Identifica um "nó" de conversa
- Sem espaços, use `_` para separar

#### Speaker
```
speaker: Dona Maria
```
- Define quem está falando
- Mostrado na UI
- "Narrator" para narração

#### Diálogo
```
Dona Maria:
    A água subiu muito rápido...
    A gente precisa sair daqui.
```
- Texto mostrado na dialogue box
- Quebras de linha = novas frases
- Reticências (...) para efeito dramático

#### Opções (Branches)
```
    - [Ir para o abrigo] -> opcao_abrigo
    - [Procurar casa de amigos] -> opcao_amigos
    - [Ir para hospital] -> opcao_hospital
```
- Formato: `- [Texto visível] -> próximo_nó`
- Quantidade ilimitada
- Player seleciona uma

#### Condições
```
if state.visited_shelter:
    speaker: Dona Maria
    Obrigada por me ajudar no abrigo!
```
- Usa variáveis de `Globals.gd`
- Condicional simples

#### Sinais (Triggers)
```
speaker: Dona Maria
[signal mission_complete]
Você conseguiu!
```
- Ativa evento no código
- Usado para verificar conclusões

## 💬 Exemplo Completo

```dialogue
# Dona Maria - Primeira Conversa

start:
    speaker: Dona Maria
    Ah, você viu como subiu rápido?
    A água tá entrando até na sala...
    - [Você precisa sair daqui!] -> conselho
    - [Já avisei para alguém?] -> aviso

conselho:
    speaker: Dona Maria
    É verdade... Onde a gente vai?
    - [Procurar um abrigo] -> abrigo_route
    - [Ir para casa de parentes] -> parentes_route

aviso:
    speaker: Dona Maria
    A Defesa Civil já passou aqui...
    Disseram para todo mundo evacuarem.
    - [Para onde vão os vizinhos?] -> defesa_civil
    - [Você tem lugar para ir?] -> lugar_ir

abrigo_route:
    [signal escolheu_abrigo]
    speaker: Dona Maria
    Tem um abrigo na escola ali perto...
    Vamo junto então?
    -> end

parentes_route:
    [signal escolheu_parentes]
    speaker: Dona Maria
    Meu primo fica lá no Alto Santa Teresinha...
    Mas pra chegar lá é longe com essa chuva...
    -> end

defesa_civil:
    speaker: Dona Maria
    Muitos foram pro abrigo que abriram na escola.
    Tem comida lá, e a Defesa Civil cuida...
    -> abrigo_route

lugar_ir:
    speaker: Dona Maria
    Não sei... Esse bairro é tudo alagado.
    E meus pertences... Deixa eu levar algo.
    -> conselho

end:
    [signal dona_maria_primeira_conversa_completa]
```

## 🔗 Integração com Código

### Mostrar Diálogo em GDScript

```gdscript
# Carregar e mostrar diálogo
var dialogue_resource = load("res://dialogues/missao_01/dona_maria.dialogue")
DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

# Aguardar término
await DialogueManager.dialogue_ended
print("Diálogo completado!")
```

### Receber Sinais do Diálogo

```gdscript
# Em DialogueSystem.gd ou seu script
func _ready():
    DialogueManager.dialogue_signal.connect(_on_dialogue_signal)

func _on_dialogue_signal(letter: String):
    match letter:
        "mission_complete":
            mission_complete()
        "escolheu_abrigo":
            player_chose_shelter()
        "escolheu_parentes":
            player_chose_relatives()
```

### Acessar Variáveis de Estado

```gdscript
# Em Globals.gd (autoload)
var visited_shelter: bool = false
var escolheu_abrigo: bool = false
var donaria_mood: String = "worried"
```

Então no diálogo:
```dialogue
if Globals.visited_shelter:
    speaker: Dona Maria
    Obrigada pelo abrigo de ontem!

if Globals.escolheu_abrigo:
    speaker: Dona Maria
    Ainda estou no abrigo... Obrigada por me ajudar.
```

## 📋 Diálogos Planejados - Missão 01

### Dona Maria
- [x] Primeira conversa (chuva intensa)
- [ ] Conversa no abrigo
- [ ] Conversa pós-enchente
- [ ] Diálogos sobre aluguel social

### Funcionários do Abrigo
- [ ] Boas-vindas
- [ ] Informações sobre abrigo
- [ ] Oferecimento de comida/colchão

### Agentes da Defesa Civil
- [ ] Alerta sobre evacuação
- [ ] Direcionamento ao abrigo

### Assistentes Sociais (futuro)
- [ ] Informações sobre programas
- [ ] Cadastro para benefícios

## 🎨 Customizing Balloons

A apresentação visual do diálogo é definida em:
- `dialogues/balloons/dialogue_balloon.tscn`

Modificável em Godot:
1. Abra a cena
2. Customize:
   - Fonte (font)
   - Cores
   - Tamanho de caixa
   - Posição

## 🐛 Troubleshooting

### Diálogo não aparece
- Verificar caminho do arquivo (use `load()`)
- Confirmar nome do nó inicial (ex: "start")
- Ver console para erros

### Sinais não acionam
- Verificar conexão do signal
- Nome do sinal deve estar em `[signal nome]`
- Confirmar escuta com `.connect()`

### Opção não funciona
- Verificar sintaxe: `- [Texto] -> proximo_no`
- Confirmar que `proximo_no` existe
- Sem espaços extras

## 📚 Recursos

- [Godot Dialogue Manager Docs](https://github.com/nathanhoad/godot_dialogue_manager/wiki)
- [Dialogue Manager YouTube](https://www.youtube.com/watch?v=dMER0t8iRy4)

## ✅ Checklist Novo Diálogo

- [ ] Arquivo criado em pasta correcta (`dialogues/missao_XX/`)
- [ ] Nó `start` definido
- [ ] Speakers têm nomes
- [ ] Opções têm nós destino
- [ ] Sinais importantes adicionados
- [ ] Testado em cena
- [ ] Sem `print()` de debug
- [ ] Committed com mensagem descritiva

---

**Última atualização:** 2025-05-25  
**Mantido por:** José Daniel Silva do Carmo
