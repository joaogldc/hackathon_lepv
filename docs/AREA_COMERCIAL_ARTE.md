# Área comercial — arte MundoDosUrsos2

Integrada a arte enviada em `MundoDosUrsos2`, mantendo o projeto multiplayer existente.

- Sprites, produtos de exemplo e arquivos do Inkscape: `assets/cenario/comercial/`.
- Placas das lojas e retorno: `assets/cenario/placas/`.
- Cena visual adaptada: `scenes/world/commerce_art.tscn`.
- Cena usada pelo jogo: `scenes/world/commerce.tscn`, com `scripts/world/commerce.gd`.
- Vitrines editáveis: `scripts/world/shop_window.gd`. Cada vitrine mantém seis marcadores e aceita produtos em `produtos` no Inspetor.

O chão ocupa a área do mundo já usada pelo jogo. Lojas e objetos mantêm escala uniforme, sem esticar as fachadas. Os sprites usam a altura dos pés para aparecer à frente ou atrás dos jogadores. As bases das lojas, postes e cavaletes também são consideradas na colisão do servidor.

A cena de origem para um jogador não foi usada como cena principal: seus portais locais e seu personagem foram removidos da cena visual adaptada. Os jogadores, a entrada/saída da área, o mapa e o retorno à praça continuam sob o controle da rede existente. A compra de produtos e os interiores das lojas continuam fora desta integração.

## Verificação

Godot 4.7.2: importação, teste `commerce_art_smoke.tscn` e `commerce_smoke.tscn` com dois processos reais. Foram verificados recursos, proporções, vitrines, ordenação, colisões, presença por área, caminhada e retorno à praça.

O teste de comércio foi atualizado para o retorno automático por proximidade que o projeto já usa, incluindo a posição segura de retorno armazenada pelo servidor.

## Revisão de HUD

As propostas revisadas estão em [hud/revisao-02](hud/revisao-02/README.md), e os componentes em `assets/ui/cartas/`. São arquivos de arte e prévia: esta entrega não substitui o `duel_ui.gd` nem altera o balanceamento do duelo. O HUD do mundo com minimapa e o passaporte aprovados foram preservados.
