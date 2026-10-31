# Duelo matemático — lógica inicial

## Jogar

Reabrir o projeto para carregar o novo autoload `Duel`. Executar duas instâncias,
criar a sala na primeira e conectar a segunda. Em ambas: M → Bosque da Sabedoria →
caminhar até a seta da entrada do dojo → Procurar adversário. A fila combina dois jogadores disponíveis.
Entrar no bosque ou no dojo, sozinho, não inicia uma partida.

O bosque agora é uma área caminhável, com exterior provisório para receber a arte
do colega. Veja [praça e bosque](PRACA_E_BOSQUE.md). O fluxo é bosque → caminhar
até o dojo → fila → duelo.

## Regras implementadas para teste

- Conteúdo inicial escolhido para o protótipo: multiplicação. Adequação ao público
  e balanceamento ainda precisam de revisão da equipe.
- Cada jogador inicia com 5 de energia e 5 cartas: 2 fáceis, 2 médias e 1 difícil.
- Fáceis: 12–25 × 6–15; médias: 26–60 × 12–30; difíceis: 51–99 × 31–79.
  Todas causam 1 de dano. As alternativas incluem erros próximos de transporte
  e valor posicional, sem respostas repetidas. A explicação decompõe um fator
  em dezenas e unidades para mostrar como calcular mentalmente.
- O atacante escolhe a dificuldade. O defensor responde uma questão com quatro opções.
- Acerto bloqueia; erro ou tempo esgotado retira 1 energia. A resolução mostra explicação.
- Escolha da carta: 25 segundos; ao expirar, o servidor usa uma carta disponível.
- Resposta: 30/40/50 segundos nas cartas fácil/média/difícil. Resolução visível
  por 3,5 segundos. Os papéis alternam.
- Fim por energia zerada ou 10 turnos. Ganha quem tiver mais energia; igualdade é empate.
- O primeiro da fila começa atacando. Cada participante ataca até cinco vezes.
- Sair do dojo, mudar de área ou desconectar durante o duelo concede vitória ao adversário.
- Sair da fila cancela a busca. Nova partida exige procurar adversário novamente.
- Moedas, inventário e persistência ainda não estão integrados.

## Integração com a arte

`Duel` (`scripts/minigames/math/duel_service.gd`) é um autoload com caminho estável
em todos os clientes. A lógica permanece nele enquanto a interface e o exterior
são substituídos. `scripts/minigames/math/duel_ui.gd` é a interface provisória.

A futura entrada física do dojo deve abrir a interface. O jogador escolhe entrar
na fila com `Duel.act("join")`. A interface escuta `Duel.changed` e lê `Duel.view`.
Comandos: `card` recebe dificuldade 0–2; `answer` recebe índice da alternativa;
`leave` cancela busca ou abandona partida. Toda ação é validada no servidor usando
ID da conexão, partida, revisão do estado, fase, turno e cartas disponíveis.

Os snapshots públicos não contêm a resposta correta nem a explicação antes da
resolução. Estados: waiting, choose, answer, resolve e finished. A resposta final
inclui energia, vencedor, acertos e tentativas de cada jogador; não concede moedas.
O mapa continua disponível em M. A viagem para fora da área encerra a participação.

## Verificações executadas

Godot 4.7.2:

- Importação e execução sem erros de script.
- Dois processos reais: partida de 10 turnos, vencedor consistente, revanche e
  desconexão; código 0 em ambos.
- Rejeição de comando fora do turno e de revisão antiga; resposta não enviada nos snapshots.
- Teste de regras: escolha automática por tempo esgotado, dano por resposta expirada
  e empate com dez defesas corretas; código 0.
- Telas de escolha de cartas e pergunta renderizadas e inspecionadas visualmente.

Repetir teste de rede em dois terminais, porta 9080 livre:

```powershell
godot --headless --path . res://tests/duel_smoke.tscn -- --test-host
godot --headless --path . res://tests/duel_smoke.tscn
```

Esse teste acelera apenas o intervalo de resolução no servidor de teste, mantendo
os limites de tempo normais do jogo. Publicação web, teste pedagógico e equilíbrio
entre dificuldades permanecem pendentes.

## Arena e HUD de cartas

A interface agora mostra dois ursos animados frente a frente em uma arena de dojo,
com nome e energia de cada participante. As cinco cartas iniciais aparecem em
leque na parte inferior central: duas fáceis, duas médias e uma difícil. Cartas
consumidas saem da mão; o leque se recentraliza. Apenas o atacante pode selecionar
cartas. Passar o mouse destaca e eleva a carta disponível. O defensor escolhe
entre quatro alternativas no centro da arena. As regras permanecem no autoload Duel.

Verificado no Godot 4.7.2: importação, renderização de ataque e defesa, seleção
por sinal do botão da carta, partida completa de dez turnos, revanche e desconexão
em dois processos (ambos código 0). Inspeção visual confirmou o leque dentro da tela.
O cenário interno é provisório e pode receber a arte do colega.

## Atualização da sala de aula

O interior usa a arte nova e possui espectadores sentados às mesas. As saídas
agora geram aviso persistente de vitória/derrota. Veja [SALA_DE_AULA.md](SALA_DE_AULA.md)
para instruções, transições contínuas e testes.
