# Corrida Glacial e Foguete de Madeira

Implementação inicial baseada no documento de game design fornecido em 31/10/2026.
As novidades de `origin/main` até `3adb7a7` foram incorporadas sem remover material de arte ainda não integrado.

## Entradas e controles

- Porto Glacial → prancha do navio → deque → aproxime-se de um bote e pressione **E**.
- Observatório, pela saída direita da praça ou pelo mapa → Foguete de Madeira.
- Corrida: **W/S** ou **↑/↓**. Os três adversários são ursos simulados; não são outros jogadores conectados.
- Foguete: **WASD/setas**. Pegue potes de mel e evite abelhas. A subida muda da atmosfera para o espaço.
- **Esc** retorna. No fim, é possível revisar as respostas erradas ou escolher outro ano.
- Cenas independentes para abrir no editor: `scenes/minigames/language/corrida_glacial.tscn` e `scenes/minigames/science/foguete_madeira.tscn`. Sem conexão, funcionam como prática sem recompensas.

## Conteúdo escolar

O banco é o mesmo de `resources/education/bncc_lessons.gd`, sem duplicar questões:
Português para a corrida e Ciências para o foguete, do 1º ao 9º ano. A escolha do ano
usa a mesma preferência local da demo F2. O ano escolhido filtra o conteúdo; não há
inferência automática de domínio ou cobertura completa do currículo.

| Ano | Alternativas | Tempo | Ritmo |
|---|---|---|---|
| 1–3 | 3 | 50 s | reduzido |
| 4–5 | 4 | 38 s | moderado |
| 6–9 | 4 | 28 s | acelerado |

As perguntas apresentam habilidade, texto de apoio quando houver, dica, resposta de referência
e explicação. O baralho embaralha todas as questões da matéria/ano antes de repeti-las.
Há revisão dos erros ao final. O banco é pequeno (três questões por trilha); sua ampliação
continua necessária. A prática F2 permanece sem tempo.

Durante a pergunta, a rolagem cai para 18% do ritmo normal e o consumo de mel para 15%.
O cronômetro continua; o mel pode acabar. A colisão que abriu a pergunta é resolvida
pela resposta; outros obstáculos não causam dano escondido atrás do painel. Durante a
explicação, a ação e o consumo ficam suspensos para leitura sem pressa.

## Regras e rede

O servidor simula movimento, geração, colisão, consumo de mel, posições, cronômetro,
respostas e recompensas. Cada jogador tem sua própria partida, enquanto permanece na sala.
Isso não é uma corrida PvP sincronizada. O cliente envia apenas direção e escolha de resposta.

- Corrida: obstáculo na rota abre uma pergunta. Acerto dá impulso; erro/tempo causa lentidão e uma posição de penalidade. Moedas são coletadas por colisão.
- Foguete: mel acaba gradualmente. Acerto num pote enche o tanque e dá turbo/invulnerabilidade; erro tira oito unidades. Abelhas tiram doze e ficam mais rápidas no espaço.
- Acertos contam para as diárias/história. Concluir com ao menos dois acertos registra `reading_complete` ou `science_complete`.
- Chegar ao final concede dez moedas, somadas às moedas coletadas na corrida. Abandonar não concede prêmio de conclusão.
- Resultados e respostas são validados por fase/revisão; respostas duplicadas ou fora do prazo não contam novamente.

## Arte e limites desta entrega

As folhas originais de remo, obstáculos, moedas, foguete, abelhas e mel estão preservadas.
`scripts/minigames/arcade_art.gd` define os recortes em `AtlasTexture`, sem modificar as imagens.
Fundos gerados anteriormente pelo gerador integrado foram copiados para `assets/cenario/minigames/`:
rio horizontal, subida da atmosfera e espaço orbital. Os fundos da subida usam transição suave.
O rio repete o cenário e pode mostrar emenda; a arte não foi criada como tile perfeitamente contínuo.
As folhas geradas têm pequenas variações entre quadros; ainda podem receber acabamento artístico.

A seleção do ano é local ao computador, como na demo. Não altera o perfil escolar de um sistema externo.
O caderno da demo F2 continua separado dos resultados arcade; as missões usam o progresso da sala.

## Verificação

`tests/arcade_smoke.tscn` passou no Godot 4.7.2, em modo sem janela: bancos dos nove anos,
contagem de alternativas, resposta correta preservada ao embaralhar, resposta duplicada,
tempo esgotado, penalidade de posição, revisão, prêmio concedido uma vez, mel/turbo,
fim de combustível e carregamento das duas cenas e do deque.
A inspeção visual em execução e uma sessão completa entre dois computadores ainda precisam ser feitas.
