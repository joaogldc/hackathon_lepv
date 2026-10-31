# HUD principal: Clube

**A referência aprovada é `assets/ui/clube/referencia-hud-principal.svg`.**
Ela corresponde à imagem enviada: perfil no alto à esquerda, próxima descoberta,
nome da região centralizado, moedas, minimapa circular e barra azul inferior com
emotes, conversa, mochila, amigos, passaporte e mapa. A única seção nova nessa
estrutura é o cartão de missões diárias, abaixo de Próxima descoberta.

A cena principal continua `scenes/world/lobby.tscn`. Ela carrega
`scripts/world/world_hud.gd` como HUD do mundo. Os controles são nativos e os
ícones originais da proposta Clube foram reaproveitados. Não se usa uma imagem
da tela inteira como interface. Nome, região, saldo e missões usam o estado
local; o rótulo inicial de nível é 1, sem introduzir um novo sistema de níveis.

## Lojas separadas por ambiente

- Entre pela porta da loja de pets na área comercial. Aproxime-se do balcão e
  pressione **E** ou clique em **Comprar pet**. Abre somente a compra de pet.
- Entre pela porta da loja de cosméticos. No balcão, **E** ou **Comprar
  cosméticos** abre somente o catálogo de roupas e acessórios, com paginação.
- Na loja de cosméticos, entre pela porta do provador, no fundo à direita.
  Diante do espelho, **E** ou **Experimentar roupas** abre a prévia. A compra é
  feita no balcão; aqui você experimenta e guarda uma peça que já possui.
- A seta inferior de cada interior volta para o ambiente anterior.
- **Q** abre as missões. **Esc** cancela a confirmação ou fecha o painel.
- **M** e **P** continuam abrindo mapa e passaporte.

Não há central de compras, abas para pular entre lojas nem atalho L que compre
fora delas. O painel fecha ao sair do balcão/provador ou mudar de ambiente. As
portas e os retornos são validados pelo servidor na navegação existente.

## Roupas recebidas e organização

`assets/sprites/urso/roupas/` contém os seis atlas, SpriteFrames, ícones, vetores
e quadros. O script original fica em `assets/sprites/urso/roupas.gd` e a cena
reutilizável em `scenes/player/roupas.tscn`. As dez variações recebidas aparecem
no catálogo: três camisas, três ternos, dois chapéus e duas toucas.

Os atlas ativos foram reexportados dos vetores para remover o urso cinza das
camadas de roupa e manter a oclusão correta de focinho e membros. Os originais
permanecem intactos em `artwork/roupas-recebidas/`. `clothing_assets.gd` mantém
as referências dos atlas para uso no provador e no desenho do jogador atual.

## Missões e estado local

A primeira vitória recebida de `Duel.result_received` desbloqueia o selo
**Primeira vitória diária**. Empate, derrota e espectador não contam. As missões
renovam à meia-noite de Brasília; o selo fica na coleção.

O perfil de compras continua local por instalação, com 300 moedas iniciais de
demonstração. Inventário, saldo, missões e peça equipada são salvos em
`user://lojas_missoes_v1.json`. O urso local usa a peça nova com as animações
correspondentes; a roupa não é transmitida para outros jogadores. A conversa da
barra exibe um balão local, e Amigos lista os jogadores presentes na sala.
Não foi acrescentado um serviço de chat ou inventário persistente no servidor.

## Verificações

Godot 4.7.2: **68 verificações** de saldo, resgate, selo, virada do dia, portas,
retornos, bloqueio de compras fora do balcão, provador separado e animações das
seis camadas. `reward_smoke` também passou. Capturas reais da execução em
`docs/huds-lojas/`, incluindo o HUD principal e as roupas.

A conexão WebSocket entre dois processos locais não pôde ser estabelecida na
verificação anterior. Esta entrega valida as regras de navegação no processo
anfitrião; não afirma validação completa de sincronização entre dois jogadores.

Os testes devem receber `-- --hud-test` para usar um perfil isolado.

## Para passar ao repositório

O pacote corrigido usa os caminhos relativos à raiz do projeto, sem `.godot`,
arquivos temporários ou caminhos absolutos de computador. Preserve a estrutura
ao levar os arquivos ao repositório. O projeto já inclui o autoload DailyJournal.
Os caminhos deste documento são relativos à raiz do repositório.
