# HUD do duelo e Corrida Glacial — 03/11/2026

O duelo usa cabeçalho com energia em cinco segmentos, painéis creme com borda de mel e botões azul-petróleo. As cartas foram redesenhadas com um favo de mel hexagonal para fácil, dois para médio e três para difícil. Todas continuam causando um de dano. A mão aparece na fase de escolha de ataque.

O painel de resposta agora contém as quatro alternativas e o botão Confirmar. A resolução mostra o produto e a decomposição em linhas separadas, durante sete segundos. A decomposição usa dezenas e unidades inteiras.

Os dois botes do deque abrem a Corrida Glacial. Círculos dourados e letreiros destacam os pontos de entrada. A tela inicial permite escolher o ano escolar; WASD ou setas movem o bote em ambos os eixos. O contato com obstáculos inicia perguntas de português, respostas corretas dão impulso, erros tiram posição, e moedas podem ser coletadas. As três canoas rivais são controladas pelo jogo. O retorno limpa a sessão e recoloca o urso no deque. A correção de fluidez e animações está documentada em MOVIMENTO_MINIJOGOS.md.

As folhas de obstáculos/moedas já estavam na main e na pasta local. Urso remando, fundo do rio e implementação arcade foram recuperados da branch demo_educacional_bncc, sem substituir as mudanças atuais de login, navio e roupas. O banco educacional e os componentes compartilhados foram trazidos como dependências. A integração posterior do habitat de ciências e do foguete está documentada em OBSERVATORIO_E_FOGUETE.md.

Validação: teste hud_ship_smoke com 1.500 multiplicações, alternativas, limites do botão Confirmar, colisão, resposta duplicada, recompensa única, entrada pelos dois botes e limpeza da sessão. Capturas locais em .tools/hud-nova-*.png e .tools/navio-*.png. Dados de teste separados dos perfis reais.

A regressão antiga requested_fixes_smoke para antes do navio: exige entrada no provador com y < 570, mas a network.gd atual da main posiciona em y = 580. Essa divergência já existe no código recebido e não foi alterada nesta tarefa. A verificação dedicada acima cobre a nova integração; a regressão completa de provador permanece pendente.
