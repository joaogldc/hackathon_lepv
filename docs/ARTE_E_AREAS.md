# Animações e área comercial — 30/10/2026

## Frames enviados ao GitHub

Recebidos os 36 PNGs de `frames/` do commit `b84501e` de `origin/main`, identificados
pelo usuário como envio do Kilim. A atualização foi integrada por fast-forward,
preservando os arquivos locais do jogo. Os PNGs originais não foram alterados.

O personagem usa dois frames de parado e quatro de caminhada para S, N, E, NE e SE.
As vistas a oeste são espelhadas durante o desenho; o servidor transmite também
as direções diagonais. A animação de caminhada é escolhida pelo deslocamento visual
até a posição sincronizada. O urso permanece alinhado aos pés em tela de 96 × 96.

Os frames de aceno e sentado foram preservados, mas ainda não possuem comandos
ou sincronização de emotes. O contrato anterior de PNGs estáticos é uma alternativa
de fallback; os frames animados têm prioridade quando presentes.

## Organização do mundo

- Lobby: praça e quatro portais. Matemática à esquerda, português embaixo,
  ciências à direita e **área comercial no centro em cima**.
- Área comercial: cena `scenes/world/commerce.tscn`, separada visualmente do lobby,
  com duas fachadas de lojas e circulação compartilhada pelos jogadores da área.
- Portal inferior da área comercial: retorno ao ponto de entrada no lobby.
- Minijogos: continuam em cenas provisórias de integração.

Para testar: F8, recarregar arquivos alterados, F5, conectar as duas instâncias,
aproximar do portal superior e pressionar **E**. A segunda instância verá o urso
sumir do lobby; ao entrar na área comercial também, voltará a vê-lo. Para sair,
aproximar do portal inferior e pressionar **E**.

O mapa (**M**) agora mostra a ilha inteira, com os habitats e a vila das lojas.
Clicar em uma região realiza viagem direta. A versão anterior de caminhada pelo
mapa foi substituída após esclarecimento do usuário. Veja o comportamento atual
em [integração dos minijogos](INTEGRACAO_MINIJOGOS.md).

O servidor valida proximidade nos portais físicos; a viagem pelo mapa usa IDs de
destino autorizados sem exigir proximidade. Ele conserva a
posição de retorno do lobby e aceita movimento apenas nas áreas caminháveis.
Jogadores em áreas diferentes permanecem conectados, mas não aparecem um ao outro.

## Verificação repetível

Em dois terminais, com a porta 9080 livre:

```powershell
godot --headless --path . res://tests/commerce_smoke.tscn -- --test-host
godot --headless --path . res://tests/commerce_smoke.tscn
```

Os dois processos devem imprimir `COMMERCE PASS` e encerrar com código 0.
