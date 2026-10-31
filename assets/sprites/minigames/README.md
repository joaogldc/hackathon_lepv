# Artes dos minijogos — primeira versão

Criadas pela ferramenta integrada image_gen a partir das referências do jogo.
São artes de poses e objetos, sem integração automática ou teste no Godot.
Os PNGs mantêm seus canais alfa originais. Prompts integrais acompanham cada
folha em prompt_v1.txt; os arquivos existentes não foram substituídos.

## Corrida Glacial

`corrida_glacial/obstaculos_moedas_agua_v1.png` — RGBA, 1536 × 1024.
Quatro linhas de referências: obstáculos (dois gelos e dois troncos), quatro
poses de moeda, quatro estágios de splash e quatro texturas de correnteza.
Não inclui pinguim, foca nem outro competidor animal. As poses do urso no
bote estão em `../urso/remando/urso_bote_remando_v1.png`.

## Foguete de Madeira

`foguete_madeira/foguete_abelhas_mel_v1.png` — RGBA, 1122 × 1402.
Inclui quatro poses de propulsão normal e quatro de turbo; duas poses de
abelha terrestre e duas de abelha espacial; retrato da Abelha Sábia; pote
de combustível cheio, pela metade e vazio; quatro poses do coletável de mel.
O urso original foi fornecido como referência para o personagem na janela.

## Preparação para animação

As folhas geradas precisam de recortes, registro de pivôs e revisão de loop.
Não assumir que todas as células têm tamanhos uniformes. Os efeitos de brilho
têm alfa parcial; as texturas de água ainda precisam de revisão de emendas
antes de serem usadas como tiles repetidos. Não foram alteradas as mecânicas
do jogo nem executados testes de animação.
