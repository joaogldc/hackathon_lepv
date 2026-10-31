# XP, sequência de mel e navio glacial

## Testar e ajustar no Godot

- Abra `scenes/ui/recompensa_xp.tscn`, selecione **RecompensaXP** e aperte **F6**. A prévia mostra 20 XP do jogo, mais 20 XP de bônus, com subida do nível 3 para o 4.
- No Inspetor, ajuste **Xp Ganho**, **Xp Atual**, **Xp Por Nivel**, **Nivel Atual**, **Dias Sequencia**, **Bonus Xp Diario**, contagem de missões e duração. Os valores são números reais da animação, separados das imagens.
- A seção diária usa um pote de mel que enche, sete marcadores de dias e gotas de mel que voam até a barra de XP. Não usa o ícone de fogo.
- Abra `resources/progression/diarias_padrao.tres` para configurar IDs das missões obrigatórias, bônus por dia e bônus máximo.
- Abra `scenes/world/navio_deque.tscn` e aperte **F6** para explorar o deque com botes. WASD/setas movimentam; E interage; Esc sai da prévia. O salão anterior continua em `scenes/world/navio_interior.tscn` como alternativa.

## Integração ao mundo

Na vitória do duelo, o vencedor recebe primeiro a apresentação de moedas; ao fechá-la, aparece o XP. O padrão é 20 XP por vitória, editável no nó **RecompensaXP** de `scenes/world/lobby.tscn`. Derrotas e empates mantêm seus resultados existentes. Desconectar fecha ambos os efeitos e reinicia o progresso visual da sessão.

O XP exibido no jogo acumula durante a sessão. A cena não grava recompensas no servidor. O jogo não anuncia bônus diário por uma vitória isolada: ele verifica todas as missões do diário local.

A sequência de mel está ligada a `DailyJournal`: vencer o duelo, visitar as duas lojas e experimentar uma roupa. Ao concluir as três missões, o bônus aparece uma vez. Os dias e a data da última conclusão ficam em `user://sequencia_mel_v1.tres`, junto ao perfil local do aplicativo. As configurações de bônus vêm do recurso editável da cena do lobby. Se a conclusão acontecer durante a vitória, o bônus entra após as moedas; em outra atividade, a animação abre assim que não houver outra recompensa na tela.

Isso acompanha o modelo atual de lojas e diário: estado local, por instalação. Contas por aluno, XP persistente e validação das recompensas por servidor continuam pendentes. Os testes usam `--hud-test`, com persistência desativada, para preservar o perfil de quem joga.

## Regra das missões diárias

`scripts/progression/sequencia_diaria.gd` é um Resource com estado serializável. Uma instância deve pertencer a um único perfil. Ele recebe uma missão já validada e a data **YYYY-MM-DD do servidor**:

```gdscript
var estado = preload("res://resources/progression/diarias_padrao.tres").duplicate(true)
# Reutilize o MESMO estado do perfil em todas as missões e dias.
estado.registrar_missao("jogar", data_servidor)
estado.registrar_missao("acertar", data_servidor)
var resultado = estado.registrar_missao("explorar", data_servidor)
if resultado.novo_bonus:
    $RecompensaXP.mostrar(0, resultado)
```

O exemplo acima mostra o uso independente do recurso. No jogo, o lobby usa os IDs reais de `DailyJournal.QUESTS` e verifica os objetivos cumpridos. Uma futura versão online deverá fornecer eventos e data validados pelo servidor.

- Só completar todas as missões obrigatórias libera o bônus.
- Cada dia completo seguinte aumenta a sequência; perder um dia reinicia em 1 na próxima conclusão.
- Padrão: 5 XP × dias consecutivos, limitado a 50 XP. Ambos editáveis no recurso.
- Missão repetida, dia já premiado e evento anterior ao dia atual não liberam outro bônus.
- `id_recompensa` identifica o dia; a futura carteira deve validar esse identificador por perfil e registrar recompensa e estado juntos, evitando duplicação após falhas.
- O recurso é salvo com ResourceSaver e recarregado com ResourceLoader. A gravação automática atual segue o perfil local do diário, sem autenticação ou separação de contas de alunos.

## Deque glacial e área de botes

Após o ajuste solicitado pelo usuário, o destino de português abre o **Deque Glacial** ao ar livre: dois botes salva-vidas, guinchos, remos, coletes, geleiras e um pato capitão. A câmera é frontal, centralizada e levemente mais aberta, sem vista lateral. Há também mel de emergência. O salão com escadaria e piano foi preservado como cena alternativa.

Os marcadores **BoteBombordo**, **BoteBoreste** e **MelEmergencia** podem ser reposicionados no editor. Ao chegar perto de um bote e apertar E, a cena emite `bote_selecionado(1)` ou `bote_selecionado(2)`, para o futuro minigame conectar embarque, rota e perguntas. O botão de saída usa `finished(result)` e mantém a conexão. O mapa principal continua disponível.

A exploração é local, como a proposta inicial do minigame de português. Ainda não há perguntas, partida de botes, recompensas por exploração nem sincronização de posições entre jogadores nessa sala. Cada ambiente é um fundo ilustrado único, com urso e interações separados. Área caminhável, velocidade, nome da sala e textura são editáveis no Inspetor. O exterior glacial anterior foi preservado.

## Verificações

Godot 4.7.2: importação, renderização de XP e navio, teste de diárias (parcial, repetição, sequência, intervalo, limite e salvamento/releitura), XP zero, múltiplos níveis, pular e transição moedas → XP. Regressões: viagens pelo mapa, duelo em dois processos, espectadores em três e animação de moedas.
