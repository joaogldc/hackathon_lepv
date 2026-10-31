# Praça e bosque caminhável

Atualização com os arquivos de `origin/main`, commit `fcabd3d`.

## Praça

Todos os elementos enviados estão aplicados: chão (grama, flores e caminhos),
um chafariz, dois bancos e quatro arbustos floridos. Os PNGs e o SVG original
permanecem preservados em `assets/cenario/praca/`.

A base da fonte é um obstáculo elíptico validado pelo servidor. A posição de
colisão usa os pés do urso, e o movimento é subdividido para evitar atravessar
em quadros longos. A fonte tem ordenação de profundidade em relação ao personagem.
Os pontos de retorno são corrigidos caso caiam dentro do obstáculo.
Bancos e arbustos são decorativos nesta etapa.

## Bosque e dojo

O destino `math` no mapa agora é o bosque de bambu, uma área caminhável e
compartilhada. A cena do duelo é a área `dojo`, acessível somente pela entrada
física em (576, 400) no bosque. O mapa não permite viajar diretamente ao dojo.

Fluxo: M → bosque de bambu → caminhar até a seta da porta do dojo → procurar
adversário. Sair do dojo retorna ao bosque. A seta inferior do bosque retorna
à praça. A participação no duelo é encerrada ao abandonar a área `dojo`.

A arte do bosque e do exterior é provisória, pois não estava no GitHub consultado;
ela pode ser substituída em `scripts/world/bamboo.gd` pela arte do colega.

Os sprites do urso passaram a carregar de `assets/sprites/urso/frames/`, conforme
a reorganização do repositório remoto.

## Verificação

Godot 4.7.2: importação e execução sem erros de script; teste de colisão na fonte
em movimento normal e deslocamentos longos; renderização e inspeção de todos os
elementos da praça; caminhada até o dojo e retorno ao bosque; retorno ao lobby
fora da fonte. Teste `duel_smoke` com dois processos: entrada caminhando pelo
bosque, partida completa, revanche e desconexão, ambos com código 0.

Uma tentativa inicial ficou presa na ativação das setas próximas. A ativação foi
corrigida para usar a distância real da seta, e a execução final passou. Uma revisão
automática de aprovação falhou por limite de uso; após o pedido de continuação,
a autorização voltou a funcionar e as verificações acima foram executadas.
