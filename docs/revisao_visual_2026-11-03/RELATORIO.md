# Revisão visual — Mundo dos Ursos

03/11/2026. Revisão de arquivos e apresentação atual do jogo. Nenhuma arte ou regra de produção foi alterada nesta revisão.

O maior ganho está em unir a direção de arte e corrigir a apresentação das imagens existentes. Hoje a praça e algumas lojas usam desenho plano; porto, deque, mapa e observatório usam pintura com mais volume. Além da diferença de estilo, enquadramento e HUD ocultam detalhes que já estão prontos.

## O que foi examinado

- 1.576 arquivos: 1.136 em assets, 417 originais arquivados e 23 referências em docs.
- 1.453 PNGs, 121 SVGs e dois GIFs. Todos puderam ser lidos; os SVGs foram renderizados pelo Godot, e os quadros dos GIFs foram decodificados. Isso confirma leitura, não aprovação visual de todo detalhe.
- 903 conteúdos distintos por hash, apresentados em 35 pranchas. PNG e SVG da mesma arte podem contar separadamente. Os 673 arquivos adicionais são cópias byte a byte de outro arquivo; muitas são deliberadas.
- Inspeção visual das 35 pranchas e abertura de originais selecionados. Dez capturas novas das áreas ativas do jogo, com dados de teste isolados. Não foram executadas todas as combinações possíveis de roupa, pose e acessório.

## Ordem de melhoria recomendada

| Ordem | Proposta | Evidência / benefício |
|---|---|---|
| 1 | Corrigir enquadramento e área ocupada pelos cenários antigos. | Praça, bosque e lojas são comprimidos numa faixa central. Há fundos 1280×720 desenhados em 1104×436. Reorganizar área útil e HUD preservando a proporção, com revisão conjunta das colisões e posições. Trocar a arte antes disso manteria o problema. |
| 2 | Dar à HUD uma área segura e uma regra única de escala. | Cartões escondem parte da placa do bosque; a barra inferior cobre trechos de saídas nas lojas. O HUD do mundo aplica escalas diferentes em X/Y. Usar escala uniforme, âncoras e painéis contextuais/retráteis. |
| 3 | Corrigir acessórios dos pets antes de produzir mais itens. | Camadas de cor são brancas, mas não recebem a paleta do item; a vitrine e o acessório equipado podem divergir. No peixe, os acessórios deixam de ser desenhados durante emoções. Há pontas de chapéu sem margem e nove camadas traseiras vazias do terninho da arara, cuja intenção precisa ser decidida. |
| 4 | Definir uma direção visual comum, com o mapa como referência de ambiente e o urso original como referência de personagem. | Aproximar praça, comércio e bosque do tratamento de madeira, vegetação, luz e volume dos ambientes novos. Preservar rosto, anatomia e cores do urso; não substituir tudo por uma nova geração de personagem. O nível exato de detalhe é uma escolha a aprovar, não um defeito técnico. |
| 5 | Preparar cenários em camadas. | No observatório, construção e escadas estão pintadas no fundo; o espaço caminhável fica na clareira, e o telescópio é acionado por um ponto no piso. Separar chão, prédios e primeiro plano permitirá explorar a escada/porta, passar atrás de elementos e receber sombras coerentes. |
| 6 | Fechar o acabamento dos minijogos. | O rio é repetido horizontalmente, mas suas bordas não formam uma emenda contínua. Preparar margens que encaixem ou um percurso finito. Separar água/margens e nuvens/estrelas em camadas para profundidade. Manter os pivôs e a proporção já corrigidos do barco e foguete. |
| 7 | Unificar texto, moedas e sinalização. | Há fonte padrão, Lato e Baloo ExtraBold convivendo; proponho Baloo nos títulos e Lato no texto de leitura. A moeda da HUD e a coletável usam símbolos distintos. Usar um mesmo símbolo e reservar o favo à dificuldade, se essa distinção for mantida. |
| 8 | Separar material de referência e material de produção por um manifesto de uso. | O kit antigo de cartas e suas prévias mostram dano1/2/3, enquanto o jogo usa dano1 para todas as cartas e favos. A arara tem famílias antiga e atual. Identificar fonte → exportação → cena ativa, sem apagar originais ou cópias de animação automaticamente. |

## O que eu preservaria

O urso marrom/creme e sua anatomia; a organização de roupas por corpo, pescoço e cabeça; as animações atuais da arara; o tema de madeira, mel e natureza; as identidades regionais de bambu, gelo e floresta; o mapa como referência geral; a correção recente de movimentação e pivôs dos minijogos.

Eu começaria pelo enquadramento e pela HUD, depois corrigiria os acessórios. Essas mudanças aproveitam o material existente e atingem problemas demonstrados. Em seguida faria uma área antiga, preferencialmente a praça, como piloto do novo acabamento visual antes de estender o tratamento ao restante do mundo.

## Minijogos: avaliação específica

As três folhas de personagens/objetos foram vistas em prancha e em tamanho original. O foguete, as abelhas e os potes de mel têm boa leitura de função, mas a identidade do urso deve ser conferida em cada pose antes de criar variantes. O brilho do mel ajuda a destacar o coletável; é melhor controlar esse efeito do que acrescentar detalhe ao pote pequeno. Recomendo uma leve sombra/esteira de água no barco e efeitos de impulso/impacto que deixem claras as consequências das respostas, com intensidade baixa para preservar a leitura.

O sprite de obstáculo é mais importante na escala real do jogo que na folha grande: contraste e silhueta devem distinguir gelo, tronco, moeda e água. Validar em 1152×720 e numa janela menor. Guardar metadados de pivô, margem e região junto de cada animação evita novos ajustes manuais de recorte. As correções recentes de registro do casco e da escotilha já existem e não precisam ser refeitas nesta etapa.

## Pontos que não devem ser confundidos com defeitos

Máscaras de roupas brancas são intencionais e recebem cor no renderer; a falha apontada é específica da composição dos acessórios de pets. Quadros idênticos podem ser apropriados para acessórios estáticos. Quadros totalmente transparentes não são arquivos corrompidos: é preciso confirmar a intenção artística. Um SVG poder abrir não garante que textos internos apareçam no Godot; o ícone de português precisa dessa revisão, mas não foi comprovado como falha ativa da HUD atual.

## Materiais para consulta

- [Galeria pesquisável de todos os arquivos](<galeria.html>)
- [Comparação das áreas atuais](<comparacao_ambientes.jpg>)
- [Personagens, roupas e pets: achados, IDs e caminhos](<revisao_personagens.md>)
- [Cenários e originais arquivados](<revisao_cenarios.md>)
- [Interface e referências](<revisao_interface.md>)
- [Inventário completo](<inventario.json>)

As propostas desta auditoria não foram implementadas. A galeria, as pranchas, as capturas e os relatórios estão preservados nesta pasta; os links para as artes apontam aos arquivos do repositório.
