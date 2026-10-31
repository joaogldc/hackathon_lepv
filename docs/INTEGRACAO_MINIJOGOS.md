# Portais e integração dos minijogos

## Testar agora

1. Parar a execução com F8, voltar ao editor e aguardar a leitura dos arquivos.
   Se o Godot perguntar sobre arquivos alterados externamente, recarregar do disco.
2. Executar com F5 e conectar duas instâncias como antes.
3. Caminhar até um dos círculos: matemática à esquerda, português embaixo,
   ciências à direita. O portal central superior leva à área comercial separada.
4. Perto do círculo, pressionar **E** ou clicar no botão de entrada.
5. A cena provisória deve abrir. O outro jogador continua na praça e vê o urso
   desaparecer; o contador distingue pessoas na praça de pessoas online.
6. Pressionar **Esc** ou **Voltar à praça**. O urso reaparece no mesmo ponto.
7. Repetir com o anfitrião e com o visitante nos três destinos. O servidor deve
   continuar funcionando mesmo quando o anfitrião está em uma cena de minijogo.
8. Conferir desconexão: entrar em um portal com o visitante e fechar o anfitrião.
   O visitante deve voltar à interface de conexão com o aviso de desconexão.

Estas cenas apenas demonstram a navegação. Não contêm questões, partida, pareamento
1x1 ou recompensas. Entrar no mesmo destino ainda não cria uma partida compartilhada.

## Mapa da ilha e viagem direta

**M** ou o botão **Mapa** abre o mapa completo da ilha. Clicar em uma região ou
no seu botão viaja imediatamente ao destino e fecha o mapa. Não há caminhada
por clique no mapa. A região atual aparece com a indicação **Você está aqui**.

| Região | Destino |
| --- | --- |
| Vila das lojas, ao norte | Área comercial com cosméticos e pets |
| Bosque de bambu, a oeste | Duelo matemático |
| Floresta, a leste | Foguete de ciências |
| Porto de gelo, ao sul | Barco de português |
| Praça central | Lobby |

O mapa também abre com **M dentro das cenas dos minijogos** e permite viajar
entre elas. **M**, **Esc** ou Fechar fecham somente o mapa. O movimento manual
fica suspenso enquanto o mapa está aberto; WASD e setas movimentam o urso nas
áreas caminháveis quando ele está fechado. Os portais físicos com **E** continuam
como outra forma de acessar os destinos.

A viagem usa `Network.travel_to(id)`: o servidor aceita apenas IDs conhecidos,
identifica o jogador pela conexão e atualiza a presença na área. A chamada dos
portais (`request_zone`) continua exigindo proximidade. Resultados e recompensas
não são emitidos ao viajar pelo mapa. Nos minijogos reais, limpar a sessão e tratar
abandono ao sair da árvore; o pareamento e essas regras ainda não estão implementados.

Os habitats são representados no desenho provisório do mapa; os minijogos em si
continuam nas cenas de integração. Compras e interiores das lojas estão pendentes.

O teste de viagens em rede pode ser executado em dois terminais:

```powershell
godot --headless --path . res://tests/map_smoke.tscn -- --test-host
godot --headless --path . res://tests/map_smoke.tscn
```

## Áreas dos integrantes

| Responsável | Cena de entrada | ID de rede |
| --- | --- | --- |
| Pessoa 2 | `scenes/minigames/math/entry.tscn` | `math` |
| Pessoa 3 | `scenes/minigames/language/entry.tscn` | `language` |
| Pessoa 3 | `scenes/minigames/science/entry.tscn` | `science` |

Cada integrante pode substituir a cena de sua área. Usar um **Control como nó raiz**,
ocupando a tela inteira, e adicionar o jogo 2D abaixo desse nó se necessário.
A raiz deve expor o sinal:

```gdscript
signal finished(result: Dictionary)
```

Ao terminar ou desistir, emitir esse sinal uma única vez. Exemplo do contrato-alvo
para um jogo real (os placeholders enviam somente game, completed e reason):

```gdscript
finished.emit({
    "session_id": session_id,
    "game": "language",
    "correct": 3,
    "attempts": 5,
    "completed": true,
    "skills": ["interpretacao_textual"]
})
```

Os campos do contrato-alvo precisam ser definidos e validados na implementação
dos jogos. Por enquanto, o lobby recebe o sinal apenas para navegar de volta;
não interpreta o resultado nem altera saldo. A integração de recompensas exigirá
sessão emitida pelo servidor e validação contra duplicação.

Não chamar `change_scene_to_file`, `Network.leave()` ou `get_tree().quit()` para
voltar. Não pausar a árvore inteira: isso interromperia o servidor do anfitrião.
Pausar somente a simulação do próprio jogo durante leitura de perguntas.

O lobby permanece carregado e monta a cena local em um CanvasLayer separado.
O autoload Network continua ativo e mantém os demais jogadores conectados.
Para o duelo online, combinar com a pessoa 1 o pareamento e os RPCs em nós com
caminho estável nos dois peers; a cena de entrada local não sincroniza o duelo.

## Rede e validação

`scripts/core/minigames.gd` é o catálogo compartilhado. Nele ficam destinos,
posições e caminhos das cenas. O cliente solicita somente um ID ao servidor,
via `Network.request_zone(id)`.

O servidor exige jogador cadastrado, destino conhecido, presença atual no lobby
e distância máxima de 85 pixels do portal. O retorno ao lobby não exige distância.
Dentro de um destino, a posição na praça permanece congelada. A zona é incluída
nos snapshots e determina a visibilidade do urso e a tela do jogador local.

Referência: [RPCs e autoridade no Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls).

## Teste automatizado

Com a porta 9080 livre, executar em dois terminais:

```powershell
godot --headless --path . res://tests/portals_smoke.tscn -- --test-host
godot --headless --path . res://tests/portals_smoke.tscn
```

Os dois processos devem imprimir `PORTALS PASS` e encerrar com código 0. O teste
abre as cenas reais, verifica rejeição de entrada distante, visita os três destinos
com anfitrião e visitante e confere retorno, posição e visibilidade entre peers.
O posicionamento perto dos portais é preparado pelo próprio teste no servidor.
