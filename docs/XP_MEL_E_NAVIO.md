# XP, sequência de mel e Salão Ursatlântico

## Testar e ajustar no Godot

- Abra `scenes/ui/recompensa_xp.tscn`, selecione **RecompensaXP** e aperte **F6**. A prévia mostra 20 XP do jogo, mais 20 XP de bônus, com subida do nível 3 para o 4.
- No Inspetor, ajuste **Xp Ganho**, **Xp Atual**, **Xp Por Nivel**, **Nivel Atual**, **Dias Sequencia**, **Bonus Xp Diario**, contagem de missões e duração. Os valores são números reais da animação, separados das imagens.
- A seção diária usa um pote de mel que enche, sete marcadores de dias e gotas de mel que voam até a barra de XP. Não usa o ícone de fogo.
- Abra `resources/progression/diarias_padrao.tres` para configurar IDs das missões obrigatórias, bônus por dia e bônus máximo.
- Abra `scenes/world/navio_interior.tscn` e aperte **F6** para explorar o salão. WASD/setas movimentam; E interage; Esc sai da prévia.

## Integração ao mundo

Na vitória do duelo, o vencedor recebe primeiro a apresentação de moedas; ao fechá-la, aparece o XP. O padrão é 20 XP por vitória, editável no nó **RecompensaXP** de `scenes/world/lobby.tscn`. Derrotas e empates mantêm seus resultados existentes. Desconectar fecha ambos os efeitos e reinicia o progresso visual da sessão.

O XP exibido no jogo acumula durante a sessão. A carteira/perfil persistente ainda é uma integração pendente. A cena não grava recompensas no servidor. O jogo não anuncia bônus diário por uma vitória isolada: a prévia de bônus está desativada na instância do lobby.

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

As três missões são IDs de exemplo configuráveis. O controlador central das quests deverá emitir esses eventos quando as condições reais forem cumpridas; não basta abrir uma tela.

- Só completar todas as missões obrigatórias libera o bônus.
- Cada dia completo seguinte aumenta a sequência; perder um dia reinicia em 1 na próxima conclusão.
- Padrão: 5 XP × dias consecutivos, limitado a 50 XP. Ambos editáveis no recurso.
- Missão repetida, dia já premiado e evento anterior ao dia atual não liberam outro bônus.
- `id_recompensa` identifica o dia; a futura carteira deve validar esse identificador por perfil e registrar recompensa e estado juntos, evitando duplicação após falhas.
- O recurso pode ser salvo com ResourceSaver e recarregado com ResourceLoader. Não existe nesta entrega autenticação nem gravação automática por aluno: o sistema de perfil deve fornecer identidade, data e armazenamento do estado.

## Interior glacial

O destino de português agora abre um salão explorável: escadaria dupla, lustre, madeira e latão, piano, pato na sopeira e um iceberg no balde com tratamento de passageiro VIP. Aproximar-se de piano, iceberg ou chá e apertar E mostra falas curtas. O mapa principal continua disponível; sair usa o contrato `finished(result)` e preserva a conexão.

A exploração do interior é local, como a proposta inicial do minigame de português. Ainda não há perguntas, recompensas por exploração nem sincronização de posições entre jogadores dentro do salão. A arte é um fundo ilustrado único; os pontos de interação são definidos no script, e o urso é um sprite separado. O exterior glacial anterior foi preservado.

## Verificações

Godot 4.7.2: importação, renderização de XP e navio, teste de diárias (parcial, repetição, sequência, intervalo, limite e salvamento/releitura), XP zero, múltiplos níveis, pular e transição moedas → XP. Regressões: viagens pelo mapa, duelo em dois processos, espectadores em três e animação de moedas.
