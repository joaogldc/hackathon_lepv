# HUD — revisão 02

Revisão solicitada: simplificar o HUD do minijogo de cartas. O HUD do mundo com minimapa e a janela do passaporte foram preservados, inclusive os arquivos originais, sem alterações visuais.

## Cartas mais limpas

- Sai o painel de instruções do centro da arena.
- Saem rótulos redundantes, a faixa inferior, o contador da mão e o selo “Selecionada”.
- As informações da partida ficam em três painéis compactos: jogadores/energia e fase/tempo.
- Cada carta mostra apenas dificuldade e dano. A selecionada sobe e recebe uma borda dourada.
- A pergunta usa um único painel com quatro alternativas e um botão de confirmação.
- O resultado mostra o bloqueio ou dano, a solução e uma explicação curta.

Abra `prototipo.html` no navegador para percorrer as telas e experimentar seleção, resposta e resultado.

## Arquivos

As cinco telas estão em PNG e SVG editável: mundo com minimapa, passaporte, escolha, resposta e resultado. Os componentes separados ficam em `assets/ui/cartas/` no projeto. O arquivo `hud-cartas.png` tem fundo transparente, em 1280 × 720 px. O atlas de cartas tem 800 × 192 px, dividido em cinco células de 160 × 192 px: fácil, médio, difícil, selecionada e usada.

As telas e os componentes foram renderizados pelo Inkscape via MCP, reutilizando os sprites originais do projeto.

## Limites da proposta

Esta é uma revisão visual e uma prévia local, sem alterar os scripts de gameplay. Dano 1/2/3 e 8 de energia continuam ilustrativos; o serviço atual do jogo mantém suas próprias regras. Os valores precisam ser sincronizados com o servidor ao integrar a interface. A prévia alterna entre atacante e defensor para demonstrar os dois papéis e reinicia no mesmo estado de exemplo a cada tentativa.
