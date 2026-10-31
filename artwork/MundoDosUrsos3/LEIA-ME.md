# Mundo dos Ursos — arte e cenas

## Abrir
No Godot 4: **Importar** → escolha o `project.godot` desta pasta → **Importar e editar** → aperte **F5**.
Ande com as setas. Na praça, a estrada de **cima** leva à Área Comercial e a da **esquerda** leva ao Bosque de Bambus. Suba a trilha do bosque até a porta do dojo.

Se já tiver um projeto, copie para ele apenas `assets/`, `cenas/` e `scripts/` (sem o `project.godot`).

## Cenas
| Cena | O que tem |
|---|---|
| `cenas/praca.tscn` | Chafariz, arbustos, bancos e 4 placas. A saída de cima leva à Área Comercial e a da esquerda ao bosque. |
| `cenas/area_comercial.tscn` | Praça de pedra com mosaico de rosa dos ventos, Loja de Pets (esquerda), Cosméticos (direita) e food truck de lanches entre elas. Tem 2 mesinhas com guarda-sol (dá para sentar nas cadeiras), postes, floreiras, bandeirinhas e a placa de volta à Praça. Cada loja tem letreiro, placa pendurada, cavalete "Novidades da semana" e 2 vitrines. A saída de baixo volta à praça. |
| `cenas/bosque.tscn` | Bambuzal, trilha de pedras, cascalho rastelado, lanternas de pedra, fonte de bambu, cercas e o dojo. A porta do dojo leva ao interior e a trilha de baixo volta à praça. |
| `cenas/dojo_interior.tscn` | Escola-dojo: lousa com a aula do dia, palco do professor com púlpito, 12 mesinhas baixas com almofadas (corredor no meio), alunos ursos sentados de costas (2 levantando a mão), estante de livros e taiko. A porta de baixo volta ao bosque. |
| `cenas/loja_cosmeticos.tscn` | Interior da loja de cosméticos: prateleiras com roupas dobradas e chapéus, 2 araras com roupas em cabides, 2 manequins, espelho de pé, pufe para sentar, balcão com caixa e vendedor, e o **Provador** ao fundo. A porta de baixo volta à Área Comercial. |
| `cenas/provador.tscn` | Interior do provador: espelho grande com luzes, cortinas de veludo, cabides e prateleira de acessórios. O espelho **reflete o urso de frente**. Também tem um pufe e o marcador `PontoVestir`, para a futura troca de roupa. "Sair" volta à loja. |
| `cenas/loja_pets.tscn` | Interior da loja de pets: parede de aquários com peixes voadores, prateleiras de ração, potes e bacias, acessórios para pets (capacetes, laços, chapeuzinhos), gôndola de bacias, pilha de ração, aquário grande, balcão e vendedor. |
| `cenas/urso.tscn` | O jogador. |

As trocas de cena usam `scripts/porta.gd`, um Area2D com a cena de destino e o ponto de chegada.

## Arte (feita no Inkscape)
Cada pasta `fonte/` tem os arquivos do Inkscape:
- `*_sprites.svg`, `placas.svg`, `urso_frames_paginas.svg`: **um sprite por página**. Para reexportar, use *Arquivo → Exportar → Lote* e marque todas as páginas.
- `*_cena.svg`: a cena inteira montada, para visualizar ou editar o layout.
As pastas `fonte/` têm um `.gdignore` para o Godot não importar os SVGs.

### Placas (`assets/cenario/placas/`)
Com nome: norte → Área Comercial · direita → Foguete de Ciências · sul → Barco de Português · esquerda → Bosque de Bambus.
Sem nome: `placa_norte_vazia`, `placa_direita_vazia`, `placa_sul_vazia`, `placa_esquerda_vazia`. Para escrever outro nome, abra `fonte/placas.svg`, use a ferramenta de texto (T) sobre a placa vazia e exporte a página.

## Sentar
Perto de um banco (praça), de uma cadeira das mesinhas (Área Comercial) ou de um pufe (loja e provador), aparece **[Espaço] sentar**. Aperte Espaço/Enter para sentar; aperte de novo, ou uma seta, para levantar.
Para criar um lugar novo, use um Area2D com `scripts/banco.gd`, um filho `Area` (CollisionShape2D) e um filho `Dica` (Label). Ajuste a **Altura Assento** em pixels e os **Assentos**, que são as posições X de cada lugar.

## Vitrines: produtos da semana
Cada loja tem os nós `VitrineEsquerda` e `VitrineDireita`, com 6 espaços cada (3 na prateleira de cima e 3 na de baixo).
1. Abra `cenas/area_comercial.tscn` e selecione, por exemplo, `Objetos/LojaPets/VitrineEsquerda`.
2. No Inspetor, em **Produtos**, aumente o tamanho da lista e arraste os PNGs dos produtos para os espaços. Eles aparecem na hora, já no editor.
3. `Tamanho Max` controla o tamanho de cada produto (44 px por padrão).
Os produtos de exemplo ficam em `assets/cenario/comercial/produtos_exemplo/` (peixe de capacete, bacia de água, laço e cartola). Qualquer PNG com fundo transparente funciona.

## Portas das lojas
`PortaPets` e `PortaCosmeticos` usam `scripts/loja_porta.gd` e levam aos interiores. Se você deixar o campo **Destino** vazio, a porta mostra "(em breve!)".
