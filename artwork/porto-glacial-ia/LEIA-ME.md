# Mapa de descobertas + Porto Glacial

Todas as 12 imagens deste kit foram criadas com o gerador de imagens integrado. Não foram desenhadas no Inkscape. Os arquivos originais foram preservados; a preparação do kit apenas copiou imagens, leu dimensões/transparência e organizou a montagem.

## O que foi criado

- `hud/mapa-de-descobertas.png`: mapa de 12 quests, com etapas concluídas, etapa atual, bloqueios, regiões, nível e XP.
- `cenario/porto-glacial-conceito.png`: proposta visual completa da área.
- `cenario/chao-glacial.png`: chão sem os objetos altos, para montar a cena em camadas.
- `cenario/porto-glacial-montado.png`: prévia da montagem com os sprites separados, nas mesmas posições usadas pela cena do Godot.
- `elementos/`: navio polar, mamute congelado, smilodon congelado, arco da gruta, poste com lanterna, cerca de corda, cristais, pinheiro e lago com fóssil marinho estilizado. Os nove elementos têm canal alfa e fundo transparente.
- `assets.json`: dimensões, limites visíveis, pivôs sugeridos e posições usadas na montagem.
- `prompts.json`: textos completos utilizados nas gerações.

## Ver as propostas

Abra `PREVIA.html` no navegador. As abas mostram o mapa, a cena conceitual, a montagem feita com os elementos separados e o catálogo dos sprites.

Para ver no Godot, importe o `project.godot` desta pasta e execute o projeto. A tecla **M** abre/fecha o mapa de quests; **Esc** fecha o mapa. Cada objeto do cenário é um `Sprite2D` separado em `cenas/porto_glacial.tscn`, com escala uniforme e pivô no chão. É possível reposicionar os objetos pelo editor.

Este é um projeto de apresentação artística separado do multiplayer existente. Não substitui nenhuma área aprovada e não contém sistema de colisões, viagem em rede ou persistência de quests/XP. A montagem demonstra como reutilizar as imagens; o mapa é um mockup, com textos e estado de progresso ilustrativos embutidos na imagem.

## Ideia de progressão

O caminho começa no Bosque da Sabedoria, passa pelo Porto Glacial e chega ao Observatório. Cada grupo tem quatro quests. Na imagem, as três primeiras estão concluídas e a quarta está disponível. O exemplo mostra nível 3, com 60/100 XP: completar a quest de +40 XP levaria ao nível 4. Os próximos nós seriam desbloqueados em sequência; os números são uma proposta visual, sem alterar o balanceamento atual.

Para a implementação final, mantenha títulos, descrições, estados dos nós e barra de XP como controles separados do Godot, alimentados pelo progresso validado do jogador. A imagem do mapa serve como direção visual; os valores não devem ser tratados como dados reais do jogo.

## Ideias para a área

- O navio pode virar uma sala de leitura, exploração de relatos de viagem ou minijogo de português.
- Os animais congelados podem abrir desafios de interpretação e fichas de descoberta sobre a pré-história.
- A gruta pode desbloquear uma sequência especial de quests.
- O lago com fóssil pode ser um ponto opcional de investigação.

As figuras dos animais e do fóssil são estilizadas para o jogo; as futuras fichas educativas devem usar conteúdo factual próprio. As imagens conceituais e os sprites separados têm pequenas diferenças de desenho, por terem sido gerados individualmente.
