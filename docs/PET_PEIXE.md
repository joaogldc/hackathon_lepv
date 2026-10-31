# Pet peixe voador

Fonte: `assets/Cute Flying Fish Sprite Sheet.png`, recebida de `origin/main` no
commit `f17d748`. A imagem original é RGB, com quadriculado incorporado; não é uma
folha pronta de sprites transparentes nem uma grade uniforme.

Foram recortadas poses da própria imagem e removido o fundo por máscara baseada
no contorno azul e preenchimento das regiões fechadas. **Nenhuma imagem gerada
nova foi usada.** O original está preservado. Os PNGs RGBA preparados estão em
`assets/pets/flying_fish/`: frente, quatro poses laterais e duas de costas.

O processo é reproduzível com Pillow:

```powershell
python scripts/tools/prepare_pet.py
```

O recorte automático pode preservar pequenas franjas claras nas bordas do
original; a inspeção foi feita também no tamanho de uso dentro do jogo.

## Comportamento

`scripts/player/pet_companion.gd` desenha o pet com tamanho de 32 × 32 px,
flutuação suave e alternância dos frames recortados. O pet é filho visual do urso,
acompanha seu deslocamento e deriva a pose da direção sincronizada pela rede.
Nesta versão acompanha todos os ursos; inventário, compra e escolha de pets ainda
não estão integrados. O pet não tem colisão própria nem bloqueia o personagem.

A posição fica à direita na tela. Ao olhar para a esquerda ou para trás, o pet
fica em uma camada anterior ao desenho do corpo e parcialmente escondido pelo
urso; olhando para a direita fica à frente. O deslocamento ao trocar a direção
é interpolado. Há também acompanhamento dos duelistas e dos espectadores sentados.

## Verificação

Godot 4.7.2: importação e execução sem erros de script. Galeria renderizada nas
seis direções frente, esquerda, direita, costas e diagonais. Verificados offsets
à direita e camadas -1/+1 em relação ao urso. Captura inspecionada visualmente:
o corpo cobre parte do peixe na direção esquerda, enquanto à direita o peixe
fica na frente. Código 0.
