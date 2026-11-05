# Movimento dos minijogos — 03/11/2026

## Problema e correção

O barco e o foguete eram desenhados diretamente dos snapshots publicados a cada 0,1 segundo. Mesmo no anfitrião a posição só mudava em 10 Hz. O teste contínuo de teclado reproduziu apenas 3 quadros com deslocamento em 24, com saltos próximos de 25,7 px. Os testes anteriores de captura e regras não exerciam navegação contínua.

A simulação agora roda nos ticks de física. O anfitrião apresenta o estado de cada tick; clientes suavizam e extrapolam por um intervalo curto entre snapshots de 20 Hz. Mudanças de fase continuam confiáveis, e os pacotes de movimento usam sequência para impedir que um estado atrasado faça a cena recuar. Objetos possuem IDs estáveis e são suavizados individualmente. Cenários e posições das canoas rivais também têm transições contínuas.

Pressionar e soltar uma tecla envia a intenção imediatamente; um heartbeat preserva o controle em rede. Perder o foco envia parada. Os dois jogos aceitam WASD e setas em ambos os eixos, com diagonal normalizada e limites próprios. O barco antes ignorava esquerda/direita e reduzia a velocidade vertical ao combinar uma dessas teclas com cima/baixo. A pergunta de leitura agora depende de contato próximo com o obstáculo, em vez de disparar a 200 px.

Barco e foguete usam canvases de tamanho fixo com pivôs registrados. Os recortes de tamanhos diferentes não esticam mais o casco a cada remada, nem reduzem/deslocam o corpo do foguete ao trocar normal/turbo. O desenho preserva a proporção dos sprites e posiciona o corpo junto da referência de colisão.

## Validação

- arcade_movement_smoke: teclado sintético com simulação ativa, soltura, foco, diagonais, perguntas, feedback e limites. Passou em 30, 60 e 120 FPS e também com renderização OpenGL. Na amostra a 60 FPS, 24/24 quadros tiveram deslocamento, com passos máximos próximos de 3,7 px. A 30 FPS, passos de aproximadamente 7,4 px; a 120 FPS, 2,1 px.
- arcade_remote_movement: servidor e cliente WebSocket em dois processos, porta 19225, perfil de teste separado. Ambos os jogos tiveram 24/24 quadros com deslocamento, zero recuos e resposta à soltura e ao controle horizontal. Teste em loopback; não simula redes externas com latência alta.
- arcade_visual_smoke: pivôs/canvases dos oito quadros de cada personagem, escala normal/turbo, continuidade dos objetos e cenário, IDs, suavização dos rivais, contato com obstáculo e rejeição de snapshot antigo.
- observatory_smoke e hud_ship_smoke: regressões das entradas, perguntas, combustível, recompensas e saídas. Esses testes de regras desativam explicitamente os ticks de física para avançar cenários isolados; não são usados como prova de fluidez.

Logs em .tools/arcade-movement-*.log, .tools/arcade-visual.log, .tools/observatorio-test.log e .tools/hud-ship-test.log.
