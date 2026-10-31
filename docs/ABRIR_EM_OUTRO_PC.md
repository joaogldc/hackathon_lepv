# Abrir o projeto em outro computador

## Preparação

1. Instale o **Godot 4.7.2 padrão**, com GDScript. Não é necessário .NET.
2. Clone a branch `main` de `joaogldc/hackathon_lepv`, ou baixe o ZIP completo
   pelo GitHub e extraia a pasta antes de abrir.
3. No gerenciador do Godot, escolha **Importar** e selecione o `project.godot`
   da raiz do repositório. Os projetos dentro de `artwork/` são entregas de
   referência; não são a entrada do jogo integrado.
4. Aguarde a primeira importação terminar. A pasta `.godot` será recriada
   nesse computador. A importação está configurada para processar uma imagem
   por vez e usar compressão PNG sem perdas.
5. Pressione **F5** e escolha **Criar sala**. A janela inicial é 1152 × 720.
   Para o primeiro teste, execute uma instância por vez.

Não é necessário copiar `.godot`, instalar Python/Pillow, executar os scripts
de preparação das imagens nem baixar o motor usado nos testes locais.
As imagens prontas, fontes, cenas, scripts, recursos, UIDs e arquivos de
importação necessários estão versionados.

## Dois jogadores

Abra outra instância do projeto, use outro apelido e escolha **Entrar**.
No mesmo PC, o endereço é `ws://127.0.0.1:9080`. Em outro PC na mesma rede,
substitua `127.0.0.1` pelo IP do anfitrião. O anfitrião precisa permanecer aberto.

Se o executável estiver no PATH, também é possível executar na raiz do projeto:

```powershell
godot --path . -- --host
godot --path . -- --join
```

## Organização e dados

- `scenes/`, `scripts/`, `resources/` e `assets/`: projeto integrado.
- `artwork/`: originais e entregas preservadas, incluindo material ainda não
  integrado. Não apague esses arquivos por não aparecerem no jogo atual.
- `docs/`: instruções, referências e estado das integrações.
- `tests/`: verificações automatizadas, opcionais para jogar.
- `.godot/`, logs, builds e ferramentas locais: gerados, fora do Git.

As roupas são carregadas conforme o uso para reduzir a memória da abertura.
Compras, inventário, XP e missões do jogo integrado usam o servidor `Progress`.
O código recebido de uma integração antiga de mel com carteira local está
preservado em `artwork/integracao-mel-local-5f4bba5/`, junto da explicação.
O deque, as cenas de referência e os acessórios novos dos pets permanecem nas
pastas recebidas, mesmo quando ainda não fazem parte do fluxo principal.

Os perfis salvos em `user://` pertencem à instalação/servidor; eles não são
incluídos no código do projeto nem transferidos automaticamente entre PCs.
