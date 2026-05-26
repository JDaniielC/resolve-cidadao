# SFX (Sound Effects) - Resolve Cidadão

## Como Adicionar Sons

Esta pasta contém efeitos sonoros do jogo.

### Button Click Sound
Para ativar o feedback sonoro dos botões, coloque um arquivo de áudio aqui:

- **Nome esperado:** `button_click.ogg`
- **Formato:** OGG Vorbis (recomendado para Godot)
- **Duração:** ~100-200ms (som curto de click)
- **Volume:** -6dB a 0dB (evitar picos)

Exemplo de arquivos gratuitos:
- Freesound.org
- OpenGameArt.org
- Zapsplat.com

### Implementação Atual
O `scripts/ui/menu_button.gd` verifica automaticamente se `button_click.ogg` existe:
- Se encontrado: toca ao clicar no botão
- Se não encontrado: continua sem som (sem erros)

Após adicionar o arquivo, recarregue o projeto no Godot para que o ResourceLoader detecte o novo asset.
