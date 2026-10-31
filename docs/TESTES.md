# Verificações — 30/10/2026

## Atualização visual — 31/10/2026

- Importação e inicialização no Godot 4.7.2 sem erros de script.
- Praça, bosque e sala de aula renderizados e inspecionados: placas e bambus
  ocultam o urso quando ele está atrás; mesas e espectadores maiores.
- Círculo de seleção removido; pet flutua à altura do ombro.
- Placas extraídas do vetor original, com texto renderizado pelo Godot:
  Bosque da Matemática, Floresta de Ciências e Geleira do Português.

As seções abaixo registram verificações das etapas anteriores; algumas descrevem
comportamentos que foram substituídos nas etapas seguintes.

Executado com Godot **4.7.2.stable.official.ed1daf0bf**, Windows:

| Verificação | Resultado |
| --- | --- |
| Importar projeto em modo editor headless | Passou, sem erro de script |
| Executar cena principal em headless | Passou, sem erro de script |
| Dois processos nativos por WebSocket local | Passou; ambos encerraram com código 0 |
| Cliente recebe os dois jogadores | Passou no teste automatizado |
| Servidor calcula movimento; cliente recebe posição e direção direita | Passou no teste automatizado |
| Visitante desconecta e é removido do servidor | Passou no teste automatizado |
| Renderizar praça com anfitrião usando OpenGL Compatibility | Passou; captura inspecionada visualmente |

A primeira tentativa de rede dentro da sandbox expirou. O mesmo teste com rede
local permitida passou. Os logs finais contêm `SMOKE PASS` nos dois processos.
Os arquivos temporários do motor e da captura ficam fora do repositório, em
`../.tools/`. Não são dependências do projeto.

Pendentes: teste manual das quatro direções e reconexão; dois computadores na
mesma rede; exportação e execução no navegador; servidor público WSS; aplicação
dos PNGs reais do Inkscape; teste de capacidade da sala com oito jogadores.

O teste automatizado pode ser repetido conforme [DESENVOLVIMENTO.md](DESENVOLVIMENTO.md).

## Etapa de portais — verificação adicional em 30/10/2026

- Importação e execução da cena principal: sem erros de script.
- Teste com dois processos e cenas reais: `PORTALS PASS` em anfitrião e visitante,
  ambos com código 0. Verificados os três destinos, rejeição de entrada distante,
  retorno ao ponto de entrada, permanência da conexão e visibilidade na praça.
- Teclas E e Esc simuladas no motor com renderização OpenGL: entrada e retorno
  confirmados. Capturas da praça e da cena de matemática inspecionadas visualmente.
- Teste anterior de movimento WebSocket repetido: `SMOKE PASS` nos dois processos,
  ambos com código 0.
- A primeira execução do teste dos portais revelou uma corrida na preparação do
  teste: ele mudava a posição para o próximo destino antes de o cliente observar
  o retorno. Corrigido o intervalo entre as etapas; a execução final passou.

O usuário também confirmou neste chat o movimento e a conexão em duas instâncias
da etapa anterior. Ainda faltam a verificação manual dos portais pelo usuário,
a desconexão dentro do minijogo e os testes de navegador e dois computadores.

## Mapa e nova distribuição da praça — 30/10/2026

- Godot 4.7.2: importação e execução sem erros de script.
- M e Esc simulados com renderização real: mapa abriu, clique definiu destino,
  urso chegou ao ponto e mapa fechou. Capturas da praça e mapa inspecionadas.
- Dois processos, `tests/map_smoke.tscn`: chegada ao destino com movimento no
  servidor, cancelamento por intenção manual e sincronização confirmados;
  `MAP PASS`, código 0 nos dois processos.
- Portais nas novas posições: `PORTALS PASS`, código 0 nos dois processos.
- Lojas são fachadas provisórias no alto, à direita do centro. Sem compra ou interior.

## Frames do Kilim e separação da área comercial — 30/10/2026

- Integrados 36 PNGs de `origin/main`, commit `b84501e`; originais preservados.
- Importação e execução Godot 4.7.2 sem erros de script.
- Verificação em execução dos cinco conjuntos: dois frames idle e quatro walk
  carregados em cada um. Caminhada ativa e direção esquerda confirmadas.
- Inspeção visual identificou deslocamento no desenho espelhado; corrigido usando
  transformação de escala. Nova captura confirmou alinhamento com sombra e seleção.
- Lobby, área comercial, frames animados e mapa comercial renderizados e inspecionados.
- `commerce_smoke`: dois jogadores, entrada, presença por área, encontro nas lojas,
  caminhada, mapa comercial e retorno às posições originais; código 0 nos dois processos.
- Regressões `portals_smoke` e `map_smoke`: código 0 em todos os processos.

As fachadas das lojas agora ficam exclusivamente na área comercial. Aceno, sentado,
compras e interiores continuam pendentes. Testes de servidor público e navegador
permanecem pendentes.

## Correção do mapa: ilha e viagem direta — 30/10/2026

O usuário esclareceu que o mapa deve representar a ilha e permitir acesso direto
a cada região. A caminhada por clique foi retirada da interface do mapa.

- M abre o mapa da ilha com bambu/matemática, floresta/ciências, gelo/português,
  vila das lojas e lobby. Captura renderizada inspecionada visualmente.
- Input simulado no Godot: M abre, clique no habitat de bambu viaja imediatamente,
  M abre dentro da cena de matemática e Esc fecha somente o mapa. Código 0.
- Novo `map_smoke`: viagens diretas nos cinco destinos para anfitrião e visitante,
  navegação entre minijogos sem passar pelo lobby, rejeição de destino inválido,
  preservação da posição de retorno e sincronização da presença. Código 0 nos dois processos.
- Regressões `commerce_smoke` e `portals_smoke`: código 0 nos dois processos de cada teste.
- Importação e execução do projeto no Godot 4.7.2: sem erros de script.

Os habitats têm representação provisória no mapa; a implementação dos minijogos
e suas regras de abandono/recompensas continuam pendentes.

## Duelo matemático — 30/10/2026

Implementada e verificada a lógica 1x1: partida completa, empate, limites de tempo,
validação de turnos, revanche e desconexão. Código 0 nos dois processos do teste
`duel_smoke`. Telas provisórias inspecionadas. Detalhes em [DUELO_MATEMATICO.md](DUELO_MATEMATICO.md).

## Praça completa e bosque caminhável

Aplicados todos os quatro tipos de PNG da praça de `fcabd3d`. Colisão da fonte,
pontos de retorno, bosque caminhável, acesso ao dojo e duelo em dois processos
verificados no Godot 4.7.2. Capturas inspecionadas. Veja [PRACA_E_BOSQUE.md](PRACA_E_BOSQUE.md).

## Sala de aula, espectadores e resultados

Testados três processos em quatro casos de abandono, espectadores sem permissão
de jogar, partida completa e transições por borda. Novas artes renderizadas e
inspecionadas. Detalhes e limites em [SALA_DE_AULA.md](SALA_DE_AULA.md).
