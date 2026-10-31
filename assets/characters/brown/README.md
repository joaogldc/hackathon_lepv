# Exportação do urso no Inkscape

**Atualização:** o jogo agora usa os frames animados recebidos em `frames/`, com
prioridade sobre os PNGs estáticos descritos abaixo. Veja [arte e áreas](../../../docs/ARTE_E_AREAS.md).
O restante desta página documenta o contrato inicial de fallback.

O personagem atual é provisório, desenhado por código. Quando a arte estiver pronta,
exportar PNGs transparentes nesta pasta, com estes nomes:

- `front.png`: frente.
- `back.png`: costas.
- `left.png`: esquerda.
- `right.png`: direita.

Convenção inicial: tela de 128 × 128 px em todas as imagens; centro dos pés em
`(64, 117)`. O jogo exibe cada PNG em 96 × 96 px, alinhado aos pés do personagem.
Manter a mesma escala e posição do urso nas quatro direções. O código usa o desenho
provisório nas direções ainda sem PNG. Reabrir a execução após importar imagens.

Guardar os SVGs editáveis em `assets/source/`, separados dos exports. Esta
convenção é uma proposta técnica inicial para alinhar com a pessoa 4.
