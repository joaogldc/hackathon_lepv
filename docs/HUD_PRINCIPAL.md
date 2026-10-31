# HUD Clube integrada

A HUD usa os ícones e a composição recebidos em `assets/ui/clube/`, com
controles reais para perfil, nível, moedas, próxima descoberta, diárias,
minimapa da área e barra inferior. O saldo e a barra de XP vêm de `Progress`.

## Controles e compras

- E ou botão de contexto perto do balcão: catálogo da loja atual.
- Pets: peixe inicial e papagaio por 140 moedas; equipar exige estar no balcão.
- Cosméticos: dez roupas recebidas, cartola e laço rosa, com paginação e
  confirmação. Os preços recebidos foram mantidos (70 a 160 moedas).
- No provador, E abre a prévia das roupas. Experimentar é livre; vestir uma
  peça exige possuir o item. Há um botão para retirar a roupa.
- Q ou o cartão de diárias: diário novo. O botão **Mapa da história** abre as
  12 missões existentes. É possível alternar de volta para as diárias.
- B / Pet: oito expressões do companheiro; 1 a 8 ativam diretamente no mundo.
- M: mapa de viagem. P: passaporte, incluindo a coleção do primeiro selo.

O servidor valida o balcão, o item, o saldo e a posse. Comprar duas vezes não
cobra novamente. Inventário, saldo, roupa equipada, pet e selo são salvos no
perfil existente. As roupas aparecem nos outros jogadores, no espelho, nos
lutadores e nos espectadores sentados. Os itens já equipados de perfis antigos
são preservados na migração.

`DailyJournal` agora é um adaptador de apresentação para o estado do servidor.
Não mantém uma segunda carteira local nem concede 300 moedas de demonstração.
As três diárias e a sequência existentes continuam valendo, com XP automático,
+50 XP por completar todas e renovação à meia-noite UTC do servidor.

## Primeiro selo e recompensas

O selo **Primeira vitória** é concedido uma única vez pelo servidor ao vencer
um duelo, inclusive por abandono do adversário. Ele permanece na coleção após
a renovação diária. Derrota, empate e espectadores não recebem o selo.

A animação de moedas usa o valor confirmado da partida. Depois dela, a nova
animação de XP mostra apenas o XP efetivamente concedido pelo servidor àquela
partida; a apresentação não altera o saldo nem o XP. Abandono mantém a regra
anterior: resultado/moedas, sem XP de missões.

## Ambiente e verificação

A seta do dojo foi reduzida para 60% e fica no caminho antes da escada.
O navio usa uma cópia derivada da arte recebida, sem as duas cordas pequenas
que fechavam o desembarque. A seta aponta para a entrada seguindo o plano do
chão; mastros, velas e cordame do navio permanecem intactos.

Godot 4.7.2: importação, inicialização e inspeção visual dos interiores,
catálogos e dez roupas de frente, perfil e sentadas de costas. Testes:
`shops_daily_smoke`, `polish_smoke`, `progression_smoke`, `xp_daily_smoke`,
`expansion_smoke` em dois processos e regressão do duelo em dois processos.

A conversa da barra ainda exibe um balão local; Amigos lista quem está na sala.
O perfil permanece associado à instalação/apelido no servidor escolhido,
sem conta em nuvem. A cena separada do salão glacial foi recebida e preservada;
a entrada do navio no jogo mantém o desafio de leitura validado pelo servidor.
