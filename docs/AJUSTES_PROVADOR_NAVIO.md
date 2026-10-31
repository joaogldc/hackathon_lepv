# Provador, lojas, minimapa e navio

- Provador: entrada afastada da saída, caminhada de 135 px/s em vez de 456 px/s e saída deliberada com E na passagem inferior. Andar para trás não troca mais de sala.
- Fontes: lojas usam Lato Regular; letreiros e nomes usam Lato Bold. Arquivos e licença OFL acompanham o projeto.
- Minimap: esquema simples da área atual, ponto que acompanha o jogador e marcadores de lojas, dojo, ciências, navio e saídas. O deque também mostra os dois botes no mapa local. O mapa completo mantém o shader de água e luzes animadas.
- Pets: tamanho visual aumentado em aproximadamente 31%, com acessórios acompanhando a mesma escala.
- Urso: roupas separadas em corpo, pescoço e cabeça. Equipar uma peça substitui somente a peça da mesma parte. Roupa e chapéu aparecem juntos no mundo, no espelho, no provador e no navio. A combinação é salva no perfil e incluída nos snapshots do servidor. Perfis antigos migram a peça única para a parte correspondente.
- Navio: a entrada do porto abre o deque. Ao tocar em qualquer bote, o desafio de português começa automaticamente, usando o serviço de perguntas existente. Voltar encerra a tentativa e retorna ao deque, sem disparar outra partida imediatamente. Sair do deque volta ao porto.

## Verificação

Executado com o Godot 4.7.2 da Área de Trabalho: importação, teste `requested_fixes_smoke`, regressões `shops_daily_smoke` e `polish_smoke`, além de renderização das lojas, provador e deque. Os testes usam perfil e porta isolados. A automação da janela do editor apresentou timeout; a execução e as capturas foram feitas pelo próprio Godot.
