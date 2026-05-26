# Assets - Resolve Cidadão

Organização de recursos visuais, áudio e mídia do jogo.

## 📁 Estrutura

```
assets/
├── sprites/              # Imagens e spritesheets
│   ├── backgrounds/     # Backgrounds de cenários
│   ├── characters/      # Sprites de personagens
│   ├── objects/         # Objetos do cenário
│   └── ui/              # Ícones e elementos de UI
├── music/               # Trilha sonora
├── sfx/                 # Efeitos sonoros
└── effects/             # Partículas e animações
```

## 🎨 Padrões de Sprite

### Dimensões
- **Base:** 32x32 pixels (caracteres, objetos pequenos)
- **Backgrounds:** 320x1280 (viewport match) ou tiles 32x32
- **UI Icons:** 16x16, 32x32 ou 64x64

### Formato
- Extensão: `.png` com transparência
- Compressão: Lossless (PNG)
- Codificação: RGBA para suportar alpha channel

### Naming Convention
```
tipo_nome_variacao.png

Exemplos:
- char_dona_maria_idle.png
- char_dona_maria_walk.png
- char_dona_maria_sad.png
- bg_rain_street_flooded.png
- bg_rain_street_postflood.png
- obj_water_puddle.png
- ui_phone_icon.png
```

## 🎭 Personagens

### Dona Maria
- **Pasta:** `sprites/characters/dona_maria/`
- **Estados:** idle, walk, interact, sad, worried, happy
- **Direções:** front, back, left, right
- **Tamanho:** 32x32 por frame

### Player (Jogador)
- **Pasta:** `sprites/characters/player/`
- **Estados:** idle, walk, run, interact, phone
- **Direções:** front, back, left, right
- **Tamanho:** 32x32 por frame

### NPCs Secundários
- **Pasta:** `sprites/characters/npcs/`
- Shelter worker, Civil defense officer, Residents, etc.

## 🌧️ Backgrounds

### Recife Locations
- **Rain Street (Chuva Intensa)**
  - Arquivo: `bg_rain_street_flooded.png`
  - Elementos: Rua alagada, casas coloridas, chuva
  - Versões: chovendo, chuva diminuindo

- **Shelter (Abrigo Temporário)**
  - Arquivo: `bg_shelter_interior.png`
  - Elementos: Colchões, pessoas, doações
  - Lighting: Interior, artificial

- **Post-Flood Street (Pós-Enchente)**
  - Arquivo: `bg_rain_street_postflood.png`
  - Elementos: Lama, casas danificadas, detritos
  - Atmosfera: Desolação, esperança

## 🎵 Áudio

### Música
- **Formato:** `.ogg` (Vorbis comprimido)
- **Localização:** `music/`
- **Licensing:** Creative Commons ou original
- **Loop:** Deve fazer loop suavemente

Tracks Planejadas:
- `music_rainy_tension.ogg` - Chuva intensa
- `music_shelter_calm.ogg` - Abrigo seguro
- `music_postflood_hope.ogg` - Reconstrução

### Efeitos Sonoros (SFX)
- **Formato:** `.ogg` ou `.wav`
- **Localização:** `sfx/`
- **Duração:** Máximo 3 segundos

SFX Necessários:
- `rain_heavy.ogg` - Chuva forte
- `water_flowing.ogg` - Água correndo
- `footsteps_wet.ogg` - Passos em água
- `phone_open.ogg` - Telefone abre
- `button_click.ogg` - Clique de UI
- `dialogue_next.ogg` - Próxima fala

## ✨ Efeitos Visuais

### Partículas
- **Rain:** Gotas caindo (repeat)
- **Water:** Ondulação em poças (loop)
- **Splash:** Respingo ao passo em água (one-shot)
- **Thunder:** Relâmpago (visual, um-shot)

### Animações
- Armazenar em `effects/` como `.tres` (AnimationLibrary)
- Nomear por tipo: `anim_rain_splash.tres`

## 📊 Checklist de Assets

### Missão 01 - "A Chuva Não Para"

- [ ] **Backgrounds**
  - [ ] Rain street flooded
  - [ ] Rain street reduced
  - [ ] Shelter interior
  - [ ] Street post-flood

- [ ] **Characters**
  - [ ] Player sprite (4 directions)
  - [ ] Dona Maria (sad, worried, neutral, hopeful)
  - [ ] Shelter worker
  - [ ] Civil defense officer

- [ ] **Objects**
  - [ ] Water puddles
  - [ ] Garbage floating
  - [ ] Sandbags
  - [ ] Debris

- [ ] **UI**
  - [ ] HUD icons
  - [ ] Dialogue box art
  - [ ] Phone UI
  - [ ] Choice panel

- [ ] **Audio**
  - [ ] Ambient rain
  - [ ] Thunder
  - [ ] Water sounds
  - [ ] UI clicks

## 📝 Créditos de Assets

Ao adicionar assets externos, documente:
- Nome do asset
- Autor/Fonte
- Licença (CC, MIT, etc.)
- Modificações realizadas

```
Exemplo:
- **Pixel Rain Particles** by [Autor] (CC0)
  - Modificação: Recolorido para tons tropicais
  - Arquivo: effects_rain_particles.png
```

## 🚀 Adding New Assets

1. Salve em pasta apropriada com nomenclatura correta
2. Em Godot, importe e configure:
   - Texture Filter: Nearest (pixel art)
   - Texture Repeat: Enabled (se necesário)
3. Teste em cena
4. Documente se for externo
5. Commit com mensagem descritiva

---

**Nota:** Todos os assets devem ter licença clara ou ser originais do projeto.

Última atualização: 2025-05-25
