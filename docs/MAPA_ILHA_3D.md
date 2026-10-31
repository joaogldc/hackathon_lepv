# Mapa ilustrado da ilha

O mapa de viagem usa `assets/ui/mapa/ilha-ursos-3d.png`, criado com o gerador de imagens a partir dos assets do projeto. A imagem representa uma ilha em perspectiva com relevo, volumes e sombras. A navegação continua sendo uma interface 2D no Godot.

Os cinco destinos são preservados: praça central com chafariz; vila comercial com lojas, food truck e mesas; bosque de bambu com dojo; floresta com foguete de tronco; porto glacial com navio e animais congelados. Caminhos conectam as regiões.

## No jogo

M abre o mapa. Clicar em uma região solicita a viagem pelo mesmo contrato `destination_selected` e pela validação de destinos existente. O destino atual tem uma placa verde, e as placas recebem destaque ao passar o mouse ou usar o foco do teclado. M e Esc fecham o mapa.

Nomes, descrições e indicação atual são controles do Godot; não estão escritos na imagem. A arte mantém a proporção ao redimensionar a janela. O minimapa do HUD usa a mesma imagem, e o ponto indica a região atual. Dojo pertence ao bosque; interiores de lojas pertencem à vila comercial.

## Editar e visualizar

Abra `scenes/ui/mapa_ilha.tscn` e aperte F6 para revisar a interface. O nó raiz permite trocar **Imagem Mapa** pelo Inspetor. As regiões clicáveis e os textos ficam em `scripts/world/world_map.gd`, em coordenadas proporcionais à imagem. Os arquivos não alteram missões, progressão, recompensas ou regras dos minigames.

`assets/ui/mapa/geracao.json` registra o prompt e as referências usadas na geração.
