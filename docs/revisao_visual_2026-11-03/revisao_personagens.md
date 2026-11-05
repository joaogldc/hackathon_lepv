# Revisão de personagens, roupas e pets

Inspeção de 03/11/2026. Foram vistas todas as 18 pranchas das categorias urso (2), roupas (7) e pets (9): 473 artes únicas por hash, além de originais selecionados. O inventário contém 1.012 arquivos nessas famílias, incluindo máscaras, vetores, cópias e quadros repetidos. A inspeção não equivale a executar todas as combinações de roupa, pose, pet e acessório no jogo.

## Correções prioritárias

| Prioridade | Achado e evidência | Mudança proposta |
|---|---|---|
| Alta | **A cor do acessório equipado não corresponde à vitrine.** A cartola do ícone é preta (I0182, `assets/pets/acessorios/icones/peixe_cartola.png`), mas a camada de cor é branca (I0132, `assets/pets/acessorios/cartola/cor/front.png`). O mesmo padrão aparece nos laços, chapéus e bonés. `pet_companion.gd` desenha todas as camadas com cor branca; `pet_accessories.gd` não retorna uma cor por item. | Definir uma paleta por acessório e aplicar a cor somente à camada `cor`, preservando `detalhe`. Comparar o pet vestido com o ícone da loja. Não tingir o sprite inteiro. |
| Alta | **O acessório do peixe desaparece durante as emoções.** `pet_companion.gd` define `frame=""` para o peixe quando um emote está ativo; a composição exige `not frame.is_empty()`. As emoções existem (I0730–I0737), mas não há máscaras de acessórios correspondentes. | Produzir as oito máscaras de emote por acessório ou redesenhar as expressões sobre a base existente. Manter o item equipado durante a reação. |
| Alta | **Alguns acessórios não têm margem e já parecem cortados na borda.** A ponta do chapéu de festa termina na borda superior do PNG: I0154 (`assets/pets/acessorios/festa/cor/side_1.png`) e I0381 (`assets/pets/acessorios_arara/festa/cor/lado_1.png`). Outros quadros de festa/cartola tocam y=0; o capacete lateral do peixe toca x=128 (I0126–I0129). | Reexportar base e camadas com um canvas comum maior, preservando os pivôs. Validar a ponta e o aro completos sobre fundos claros e escuros; aumentar apenas a imagem de uma camada deslocaria a sobreposição atual. |
| Média | **Nove quadros do terninho da arara estão completamente transparentes.** I0627–I0635: `assets/pets/acessorios_arara/terninho/cor/costas_1.png` a `costas_9.png`; o inventário confirma bbox de alfa vazio e 100% de transparência. | Decidir se o terno deve aparecer nas costas. Se sim, desenhar a parte traseira; se for oclusão intencional pelas penas, registrar essa decisão. Não tratar como arquivo corrompido. |

## Melhorias visuais propostas

1. **Preservar o urso como base de identidade.** Os quadros do urso, roupas e arara usam formas simples e contornos definidos; o peixe tem volume brilhante, reflexos e saturação maiores (compare I0784/I0795, I0711 e I0738). O peixe chama mais atenção que o personagem principal. Proponho reduzir o brilho e simplificar sua sombra para aproximá-lo da mesma família visual, preservando cor azul e formato das nadadeiras. É uma decisão de direção de arte, não um erro de arquivo.
2. **Revisar a silhueta dos acessórios na escala real.** Os acessórios ocupam uma pequena fração dos canvases de 128×128 ou 288×256 e o pet aparece com cerca de 42 px de largura no jogo. Bigode, gravata e o emblema do quepe podem desaparecer visualmente. Fazer a aprovação em 42 px e na vitrine antes de aumentar detalhe. Um contorno um pouco mais forte e menos detalhes seriam melhores que elevar a resolução.
3. **Dar ao urso reações próprias.** Há aceno e poses sentando (I0791–I0792 e I0801–I0804), mas o jogador comum usa essencialmente idle/walk/sit. Proponho comemoração, erro pensativo e impulso para feedback de aprendizagem. Reutilizar a anatomia dos vetores atuais, sem gerar outro urso.
4. **Escolher a arara canônica e documentar o legado.** O jogo já usa `assets/pets/arara/quadros/` para animação e encaixe dos acessórios. `assets/pets/parrot/` mantém um conjunto anterior de 128×128 e emotes de 160×160 (I0743–I0757), além do conjunto atual de 288×256 (I0683–I0727). Isso aumenta a chance de alguém integrar o PNG errado. Manter originais, mas marcar claramente a família ativa e a de referência; só remover cópias após conferir referências.

## Pontos que exigem teste de composição

- **Urso sentado em perfil:** existe corpo `E_sit.png` (I0765) e roupa `E_sit.png` (por exemplo I0841). Entretanto, `bear.gd` escolhe `S_sit` para todo sentado que não está de costas; `cosmetics.gd` escolhe `sit_E` para direções esquerda/direita. Os assentos de mundo atualmente forçam `direction="front"`, portanto o problema não está demonstrado em todos os assentos atuais. É uma divergência latente: alinhar a escolha do corpo e da roupa antes de habilitar assentos laterais.
- **Roupas brancas não são defeito.** Os atlas `*_cor.png` são máscaras para tingimento. `cosmetics.gd` aplica `product.color` e mantém as camadas `detalhe` sem tingimento; essa estratégia está coerente. Não substituir essas máscaras por roupas já coloridas.
- **Não apagar quadros iguais automaticamente.** Vários acessórios de cabeça são estáticos entre quadros de voo. Igualdade de hash pode ser deliberada. O ganho seguro é compartilhar referências no recurso de animação, mantendo os nomes e registros esperados pela composição.

## Preservar

- Anatomia, paleta marrom/creme e leitura do rosto do urso.
- Separação de roupa em corpo/pescoço/cabeça e camadas cor/detalhe.
- As dez fases laterais e nove de costas da arara, já aproveitadas pelo renderer atual.
- Canvases e pivôs comuns para cada família; qualquer reexportação precisa manter a correspondência entre base e sobreposição.
