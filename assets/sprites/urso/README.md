# Urso — sprites

Personagem original no estilo cartoon de Club Penguin. Cada frame tem 256×256 px, com fundo transparente.

## Arquivos
| Arquivo | O que é |
|---|---|
| `urso_spritesheet.png` | Folha 6×6 com todos os frames |
| `urso_frames.tres` | SpriteFrames do Godot 4, com todas as animações configuradas |
| `urso.gd` | Script de movimento em 8 direções (CharacterBody2D) |
| `frames/` | Cada frame em PNG separado |
| `fonte/urso_sprites.svg` | Fonte vetorial editável no Inkscape (uma camada por animação; corpo e braço são clones de formas mestre) |

## Layout da folha
| Linha | Direção | Colunas 1–2 | Colunas 3–6 |
|---|---|---|---|
| 1 | S (frente) | idle | walk |
| 2 | SE | idle | walk |
| 3 | E (lado) | idle | walk |
| 4 | NE | idle | walk |
| 5 | N (costas) | idle | walk |
| 6 | — | wave_S (col. 1–4) | sit_S (5), sit_E (6) |

W, SW e NW são E, SE e NE com `flip_h = true`.

## Uso no Godot
1. Mantenha esta pasta em `res://assets/sprites/urso/`. O `.tres` aponta para esse caminho.
2. Crie um `CharacterBody2D` com um `AnimatedSprite2D` filho e coloque `urso_frames.tres` em *Sprite Frames*.
3. Anexe o `urso.gd` ao `CharacterBody2D` e adicione uma colisão.
4. A origem do frame fica no centro. Os pés ficam cerca de 110 px abaixo dele, então use `offset.y = -110` se quiser o pivô no chão.
