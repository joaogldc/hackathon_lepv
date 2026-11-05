# Revisão de interface e referências — 03/11/2026

## Cobertura e limite

Inspecionadas integralmente as duas pranchas `interface-01/02.jpg` (44 imagens únicas, incluindo duas folhas de pets que caíram nessa categoria pelo caminho) e `referencias-01.jpg` (23 imagens únicas). Também foram abertas as capturas atuais `.tools/hud-nova-cartas.png`, `hud-nova-conta.png`, `observatorio-janela-menor.png` e `navio-corrida.png`, além dos originais do mapa de descobertas e da captura histórica do mapa. Conferidos scripts de HUD, cartas, lojas, arcade, mapa e missões.

Não houve alteração de artes ou código. As propostas abaixo não são uma nova direção aprovada. Os PNGs históricos e os SVGs editáveis não foram tratados como prova de funcionamento atual.

Conferidas também as capturas reais recém-geradas em `runtime/lobby.png`, `runtime/loja_cosmeticos.png`, `runtime/provador.png` e `runtime/dojo.png`.

## Prioridades

| Prioridade | Evidência confirmada | Proposta e benefício |
|---|---|---|
| Alta | Em `runtime/lobby.png`, os cartões laterais de progresso/diárias encobrem parte da placa esquerda do bosque. Em `runtime/loja_cosmeticos.png` e `runtime/provador.png`, a barra inferior ocupa a faixa da seta de saída. | Definir uma área segura para placas, portas e setas; recolher cartões de missão quando o jogador estiver perto de uma saída ou num interior. Reposicionar os objetos interativos antes de mudar a arte: o problema confirmado é de sobreposição entre HUD e cenário. |
| Alta | `scripts/world/world_hud.gd:175` escala os widgets por `viewport_size / Vector2(1280,720)`, separando X e Y. Em 1152 × 720, resulta em X=0,9 e Y=1. Já o arcade usa proporção uniforme. | Preservar proporções da HUD com escala uniforme e reposicionamento por âncoras. Evita comprimir ícones, círculos e letras horizontalmente e faz a interface manter o mesmo aspecto entre mundo e minijogos. É uma correção de apresentação, não exige regenerar artes. |
| Alta | Arcade aplica Baloo2 ExtraBold a todos os textos (`arcade_game.gd:61–64`), incluindo leitura e instruções. Duelo usa Lato Bold, lojas Lato Regular, HUD do mundo não define fonte de corpo explícita. A diferença é visível na captura de preparação do foguete. | Usar Baloo apenas em títulos e Lato Regular/Semibold em explicações, perguntas e botões. Definir uma única hierarquia de tamanhos e espaçamentos. Reduz densidade e torna a leitura dos exercícios mais confortável. É melhoria editorial/visual, não falha de arquivo. |
| Média | A moeda da HUD principal usa símbolo parecido com € (`I1113`, `assets/ui/clube/icone-coin.svg`, carregado em `world_hud.gd:139`), enquanto lojas/recompensas usam moeda com estrela (`I1136`, `assets/ui/recompensas/moeda.svg`). A moeda coletável do barco também tem estrela. | Unificar em uma única moeda com estrela, preservando o tom dourado atual, e reaproveitar o mesmo desenho em saldo, loja, coleta e recompensa. A identidade da economia fica imediata. |
| Média | Os PNGs de cartas e as referências antigas mostram dano 1/2/3 (`I1100`, `I1102`, `I1558`, `I1560`), mas `card_button.gd:42` desenha dano 1 em todos os níveis; a dificuldade agora é indicada pelos favos. Os cabeçalhos do duelo atual são desenhados por código. | Marcar os arquivos antigos como referência histórica e atualizar um único kit de produção com favos, dano real e estados normal/selecionado/usado. Isso evita integrar uma arte que contradiga o jogo. Não substituir regras do servidor pelos números ilustrativos do mockup. |
| Média | O ícone de português (`I1115`, `assets/ui/clube/icone-language.svg`) aparece como quadrado vazio na renderização SVG feita pelo Godot. O “Aa” ainda está em um elemento `<text>` no arquivo. O passaporte atual escreve `Aa` como texto nativo e não foi encontrado carregamento direto desse ícone nos scripts atuais. | Converter as letras desse ícone em caminhos vetoriais antes de reutilizá-lo, ou manter o texto como controle nativo. É defeito latente do asset; não afirmar que o passaporte atual está vazio. As prévias SVG de telas completas também perdem textos, mas essas são referências editáveis. |
| Média | O mapa de descobertas (`I1129`) traz nível, XP, botões, cadeados e missão de exemplo pintados no PNG. `discovery_map.gd` sobrepõe painéis e uma rota larga para esconder os valores ilustrativos. O código já tenta substituir os estados reais. | Criar uma versão de cenário limpa, mantendo floresta/porto/observatório, e desenhar todos os números, rotas, bloqueios e textos com controles. A arte deixa de competir com a interface e a manutenção não depende de cobrir rótulos gravados na imagem. |
| Baixa | Existem vários azuis de botão: mundo `#259dcb`, arcade `#258bab`, duelo `#226779`; bordas e sombras também variam. Branco sobre esses azuis tem contraste calculado de aproximadamente 3,10:1, 3,92:1 e 6,39:1, respectivamente. Creme `#fff5dc` com tinta `#513d2b` tem 9,43:1. | Definir um azul principal mais escuro para texto branco pequeno, um tom de hover e um estado desativado comum. A base creme/tinta já funciona bem e deve ser preservada. Os números são comparações de cor, não resultado de uma auditoria formal de acessibilidade. |
| Baixa | No arcade, as telas iniciais contêm parágrafos longos em peso muito alto; nas cartas, a legenda inferior repete dificuldade e dano que já estão nas próprias cartas. Capturas atuais confirmam essa densidade. | Trocar parte da introdução por três blocos curtos com os próprios sprites: colete mel/moeda, desvie, responda. Encurtar instruções persistentes e deixar explicação completa num botão de ajuda. A área de jogo fica mais limpa sem inventar novos assets. |

## O que preservar

- A combinação creme, contorno marrom e detalhes dourados já conecta cartas, lojas, mapa e mundo.
- Os favos hexagonais têm boa silhueta no tamanho das cartas. Manter nome e contagem junto da cor preserva leitura sem depender apenas do matiz.
- O mapa da ilha (`I1128`) funciona como referência geográfica forte. Os rótulos do mapa atual são controles nativos; não é preciso gravá-los na imagem.
- Os ícones de livro, mochila, mapa, amigos, ciência e escudo compartilham contorno e proporções coerentes. Recomendo refinamento pontual, não redesenho completo.
- A correção recente já mantém conta, alternativas e confirmar dentro do painel na captura inspecionada. Não encontrei novo vazamento nessa captura; não tratá-la como uma falha ainda aberta.

## Sequência sugerida

1. Corrigir a proporção da HUD do mundo e padronizar fontes de leitura.
2. Unificar moeda, cores e estados de botão num pequeno kit de interface.
3. Atualizar a referência de cartas para o estado real com favos.
4. Limpar o fundo do mapa de descobertas e separar arte de dados.
5. Fazer revisão visual nas resoluções usadas pelo jogo, sem depender somente de mockups.

## Fontes locais principais

IDs referem-se a `inventario.json`. Pranchas em `interface-01.jpg`, `interface-02.jpg` e `referencias-01.jpg`. Evidências de implementação: `scripts/world/world_hud.gd`, `scripts/minigames/arcade_game.gd`, `scripts/minigames/math/card_button.gd`, `scripts/minigames/math/duel_ui.gd`, `scripts/ui/commerce_hud.gd`, `scripts/world/discovery_map.gd`. `docs/hud/revisao-02/README.md` registra que os valores antigos de dano e energia eram ilustrativos.
