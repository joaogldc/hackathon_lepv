# Pessoa 1 — primeiro marco

Versão informada pelo usuário: **Godot 4.7.2**, edição padrão, GDScript.
Renderer Compatibility. O projeto fica na raiz do repositório.

## Abrir e testar manualmente

1. Importar `project.godot` no Godot 4.7.2 e executar com F6/F5
   (F6 somente com `lobby.tscn` aberta).
2. Na primeira janela, escolher um apelido e clicar em **Criar sala**.
3. Abrir outra instância, escolher outro apelido e clicar em **Entrar** com
   `ws://127.0.0.1:9080`.
4. Ambos devem mostrar `2 / 8 ursos na praça`. Mover cada urso com WASD ou setas.
   Conferir frente, costas, esquerda, direita e limites da praça nas duas janelas.
5. Sair com o visitante: ele deve desaparecer do anfitrião. Entrar novamente.
6. Fechar o anfitrião: o visitante deve receber aviso e conseguir conectar de novo.

Em dois computadores na mesma rede, usar `ws://IP-DO-ANFITRIAO:9080` e permitir
a porta TCP 9080 no firewall quando solicitado pelo Windows. Esta etapa depende
da rede local e precisa de teste real.

## Linha de comando

Substituir `godot` pelo caminho do executável, se ele não estiver no PATH:

```powershell
godot --path . -- --host
godot --path . -- --join
godot --headless --path . -- --server
```

`--server` abre servidor dedicado sem adicionar um jogador anfitrião.
Os outros comandos abrem anfitrião e visitante locais.

## Teste de rede automatizado

Em dois terminais, primeiro o anfitrião e depois o cliente:

```powershell
godot --headless --path . res://tests/network_smoke.tscn -- --test-host
godot --headless --path . res://tests/network_smoke.tscn
```

O teste exige que os dois processos vejam os dois jogadores, que o servidor mova
o visitante, que o cliente receba posição/direção e que a desconexão remova o
visitante. Cada processo deve imprimir `SMOKE PASS` e sair com código 0.
Não rodar com outra sala já ocupando a porta 9080.

## Organização e decisões desta etapa

- `scripts/network/network.gd`: autoload, conexão, cadastro, intenções de movimento,
  simulação no servidor e snapshots a 20 Hz. Até oito jogadores na única sala.
- `scripts/world/lobby.gd`: praça, interface e instâncias visuais dos jogadores.
- `scripts/player/bear.gd`: interpolação e apresentação em quatro direções.
- `assets/characters/brown/README.md`: contrato inicial para PNGs do Inkscape.

O cliente envia direção de movimento, e o servidor calcula posição, velocidade
e limites. O ID vem da conexão; o cliente não escolhe o ID que movimenta.
Uma intenção sem atualização expira após meio segundo. Esta etapa não implementa
contas, persistência, inventário, lojas, emotes ou regras dos minijogos.

Os portais já abrem cenas provisórias em `scenes/minigames/math/`, `language/`
e `science/`, mantendo a conexão e permitindo retorno à praça. Veja o
[contrato para as pessoas 2 e 3](INTEGRACAO_MINIJOGOS.md). Não há recompensas nesta etapa.

## Navegador e publicação

O transporte escolhido é WebSocket, compatível com cliente web. O navegador
conecta a um servidor nativo/dedicado; não hospeda a sala. Uma publicação HTTPS
precisará de endpoint `wss://` com certificado válido e hospedagem do servidor.
Exportação web, WSS e hospedagem ainda precisam ser configurados e testados.

Referências usadas: [WebSocketMultiplayerPeer 4.7](https://docs.godotengine.org/en/4.7/classes/class_websocketmultiplayerpeer.html)
e [multiplayer de alto nível](https://docs.godotengine.org/en/4.7/tutorials/networking/high_level_multiplayer.html).
