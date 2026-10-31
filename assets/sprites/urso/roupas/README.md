# Roupas dos ursos

Pasta canônica do pacote recebido. Os seis `.tres` continuam apontando para
`res://assets/sprites/urso/roupas/`, sem caminhos absolutos de computador.

- `camisa_cor`, `terno_cor`, `chapeu_cor`, `touca_cor`: atlas com área tingível.
- `terno_detalhe`, `chapeu_detalhe`: detalhes com cores preservadas.
- `icones/`: dez ícones usados no catálogo de cosméticos.
- `fonte/`: vetores recebidos e vetores de sobreposição corrigidos.
- `quadros/`: exportações individuais correspondentes aos atlas corrigidos.

Os PNGs recebidos também continham o urso em cinza. Os atlas ativos foram
reexportados dos vetores, mantendo apenas as roupas e respeitando a oclusão do
focinho, olhos e membros. Isso permite tingir a roupa sem tingir o personagem.
Originais intactos: `artwork/roupas-recebidas/` (fora da importação do jogo).

O script original está em `assets/sprites/urso/roupas.gd`. A cena reutilizável
`scenes/player/roupas.tscn` pode ser instanciada como filha de um AnimatedSprite2D
para usar esse script. Ela contém as seis camadas com os nomes esperados.

O jogador atual usa desenho via CanvasItem, por isso `scripts/player/bear.gd`
consome os mesmos atlas através de `scripts/player/clothing_assets.gd`.
O provador usa os mesmos recursos; não há outra versão do urso ou da roupa.

As peças novas aparecem no catálogo em dez variações. A peça comprada e guardada
no provador aparece no seu urso local, sincronizada com a pose e a caminhada.
O inventário e a escolha continuam locais; a transmissão das roupas para os
outros jogadores depende da futura persistência de inventário no servidor.
