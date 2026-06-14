# MISSÃO PRINCIPAL 2: “TEIMOSIA QUE SALVA”
**(VERSÃO DE FLUXO CORRIGIDA)**

Documento de Game Design (GDD) — Ajuste de Navegação: Do Pop-up de Choro ao Encontro com Lucas
**Tipo de Missão:** Missão Principal (Jornada Obrigatória / Sequência do Tutorial)
**Fluxo de Jogo:** Ativada de forma linear e imediata após a conclusão da missão da Dona Maria. O progresso exige que o jogador se desloque fisicamente até Lucas após o alerta sonoro, ensinando navegação de curto alcance em ambiente hostil.

## 1. Gatilho de Transição e Pop-up de Alerta (Som de Choro)
**Condição de Ativação:** O jogador fecha a interface de conclusão da missão da Dona Maria.
**Mecânica:** Os controlos do jogador são travados por 1 segundo. O sistema de áudio reproduz o efeito sonoro em loop [Som de criança chorando sob a chuva]. Na tela, surge o pop-up descritivo obrigatório.

**[POP-UP NA TELA - ALERTA NARRATIVO]**
“Você ouve o choro de uma criança ecoando logo à frente na rua alagada. Vá ver o que está acontecendo!”
🔘 Botão Interativo: [ Entendido ]

## 2. Navegação até Lucas (Mecânica Ativa)
Após clicar em "Entendido", o pop-up fecha e o controlo de movimentação é devolvido ao jogador. A missão é pré-ativada no HUD do smartphone:

**📱 OBJETIVO ATUALIZADO NO CELULAR**
**INSTRUÇÃO:** Siga o som de choro e encontre a criança na calçada à frente.

**Mecânica de UX:** Um pin de exclamação azul de curto alcance (ou uma seta indicativa discreta) aparece no chão ou no minimapa apontando para o toldo comercial onde o sprite do Lucas está posicionado. O jogador deve caminhar ativamente contornando os entulhos e poças da enchente até chegar perto do NPC. Ao encostar ou interagir com Lucas usando o botão de ação, o diálogo obrigatório da história começa.

## 3. Diálogo de Abertura com Lucas
**Lucas (Sprite estático chorando / Animação de tremor):** “Não adianta… ele não quer sair de jeito nenhum! A água tá subindo…”
**Jogador (Interagindo):** “Ei, calma, pequeno! O que houve? Por que você tá aqui sozinho no meio dessa tempestade?”
**Lucas (Desesperado):** “É o meu avô, Seu Severino. A Defesa Civil avisou no rádio pra todo mundo sair por causa do risco de deslizamento do morro… mas ele diz que a casa dele aguentou 40 anos de chuva e se trancou lá dentro. Ele tá ali na subida da rua, na casa de porta azul. Não quero deixar ele sozinho!”

## 4. Atualização da Missão e Ida à Casa do Seu Severino
O diálogo com Lucas termina. O objetivo principal do jogo é atualizado formalmente na tela:

**📱 JORNADA PRINCIPAL — NOVO ALVO**
**MISSÃO:** Teimosia que Salva
**OBJETIVO:** Suba a ladeira, entre na casa de porta azul e convença o Seu Severino a sair.

O pin do minimapa muda para a casa de porta azul na subida da ladeira.

## 5. Cenário Interno e Sistema de Escolhas Equilibrado
O jogador caminha até a ladeira, interage com a porta azul e entra no cenário interno da casa. Seu Severino está estático na sua poltrona, ouvindo o rádio de pilha sobre a mesa.

**Seu Severino:** “Já disse que não saio, rapaz! Essa casa aqui eu mesmo levantei o tijolo. Daqui eu não arredo o pé por causa de chuva.”

**Selecione a abordagem correta na caixa de diálogo:**
- [ ] **Opção A:** “O senhor está sendo egoísta! Seu neto está chorando sozinho na chuva por sua causa.”
  - **Resultado:** O idoso ignora o jogador. O Medidor de Satisfação da Cidade cai. É preciso interagir novamente para tentar de novo.
- [ ] **Opção B (Aprofundamento do Erro):** “Se o senhor não sair agora, vou ter que chamar a polícia para te tirar à força.”
  - **Resultado:** Dispara a lição pedagógica de moral.
- [ ] **Opção C (Correta):** “O risco aqui é de deslizamento do morro. Bens materiais a gente recupera, sua vida não.”
  - **Resultado:** Avança para a aceitação e o dilema do rádio.

**Sub-ramificação da Opção B (Lição de Empatia):**
**Seu Severino (Indignado):** “Chamar a polícia para um velho na própria casa?! Eu não sou criminoso, rapaz! Eu trabalhei honestamente a vida inteira para construir este teto com o meu suor. Vocês mais novos acham que tudo se resolve na base da força, sem nenhum respeito pela história de quem mora aqui.”
**Mecânica:** Exibe o botão [ Pedir Desculpas ] e recarrega o painel de escolhas original para permitir que o jogador selecione a opção adequada.

## 6. O Apego Afetivo ao Rádio de Pilha
Ao selecionar a opção correta (C), Seu Severino cede, revelando seu apego histórico:

**Seu Severino:** “O morro?… Valha-me Deus. Eu achei que era só água acumulada na rua. Tudo bem, meu filho… Eu aceito ir. Mas eu não saio deste quarto sem o meu rádio de pilha antigo. Ele está comigo desde as grandes cheias de antigamente, foi o último presente da minha falecida esposa.”
**Jogador:** “Com certeza, Seu Severino. A gente leva ele sim. A própria Defesa Civil orienta que, em momentos de evacuação, as famílias devem priorizar e levar consigo documentos, remédios de uso contínuo e aparelhos de comunicação leves.”
**Seu Severino (Aliviado):** “Obrigado por entender, meu rapaz. Tem gente nova que acha que é só velharia sem valor… Bom, eu vou. Mas minhas pernas estão muito inchadas por causa da idade, eu não tenho forças para caminhar no meio dessa correnteza até o abrigo.”

## 7. Mecânica de Cidadania: Menu de Contatos
O menu de Contatos do celular abre de forma obrigatória na tela do jogador:

| Opção no Menu | Descrição Técnica na Interface | Consequência no Jogo |
| :--- | :--- | :--- |
| 📞 Guarda Municipal | Atua na segurança patrimonial, mediação de conflitos urbanos e proteção de bens públicos. | Incorreto. “A Guarda protege o patrimônio, não faz resgates climáticos.” (Repete) |
| 📞 Defesa Civil (199) | Responsável pela gestão de desastres, mapeamento de áreas de risco, evacuações e socorro a desalojados. | **CORRETO.** Aciona o transporte e encerra a missão. |
| 📞 PROCON | Atua na proteção, orientação, fiscalização e defesa dos direitos dos consumidores nas relações comerciais. | Incorreto. “O Procon gerencia direitos do consumidor, não calamidades.” (Repete) |

## 8. Conclusão da Missão e Próxima Etapa
Selecionando a Defesa Civil (199), a missão é concluída:

**🏆 MISSÃO CONCLUÍDA: TEIMOSIA QUE SALVA!**
**Notificação:** Chamada efetuada com sucesso! A equipe de resgate assistido e transporte adaptado da Defesa Civil foi acionada para remover Seu Severino e Lucas com total segurança.

Ao fechar, o SMS automático chega abrindo a etapa do Abrigo:
**Prefeitura / Coordenação do Bairro (SMS):** “Excelente trabalho de cidadania. Agora que os moradores mais vulneráveis da sua rua estão sob os cuidados e transporte seguro das equipes de resgate, dirija-se imediatamente ao **Abrigo Municipal na Escola Pública** para auxiliar na triagem e acolhimento das famílias.”

O pin do mapa altera-se automaticamente para o prédio da escola adaptada, liberando os controlos para a nova rota do tutorial.
