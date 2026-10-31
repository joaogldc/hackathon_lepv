# Documentação de Game Design e Mecânicas dos Minijogos

Este documento define o funcionamento, a lógica pedagógica e o fluxo de gameplay dos dois minijogos.

---

## 📚 1. Calibração Pedagógica por Série Escolar

Ambos os minijogos aplicam um sistema adaptativo de perguntas conectado ao perfil do aluno:

* **Séries Iniciais (1º ao 3º ano)**:
  * Questões diretas com 3 alternativas.
  * Velocidade reduzida de rolagem de tela.
  * Maior margem de tempo para responder.
* **Séries Intermediárias (4º e 5º ano)**:
  * Questões com 4 alternativas.
  * Velocidade moderada e aumento de frequência de obstáculos.
* **Séries Avançadas (6º ao 9º ano)**:
  * Questões de raciocínio lógico/múltiplas etapas.
  * Tempo de resposta reduzido.
  * Ritmo de jogo acelerado.

---

## 🏔️ 2. Minijogo 1: Corrida Glacial (Porto Glacial)

### 2.1 Visão Geral
Uma corrida de botes pelo rio do Porto Glacial onde o jogador precisa desviar de obstáculos, coletar moedas e ultrapassar os concorrentes.

### 2.2 Mecânica de Jogo & Movimentação
* **Perspectiva**: Visão superior (*Top-Down* / 3/4 Isométrica).
* **Controles**: O jogador move o bote verticalmente (para cima e para baixo) para selecionar a melhor linha de navegação no rio.
* **Coleta de Moedas**: Moedas aparecem em formações pela pista; pegar moedas incrementa a pontuação do jogador.

### 2.3 Gatilho Educativo (Desvio de Obstáculo)
1. **Aproximação**: Um obstáculo (iceberg ou tronco) aparece na rota frontal do bote.
2. **Pergunta em Tela**: O jogo reduz levemente a velocidade e exibe o painel da questão calibrada para a série do jogador.
3. **Resultado**:
   * **ACERTO**: O urso executa um desvio perfeito, ganha um *boost* instantâneo de velocidade e ultrapassa ou mantém sua liderança.
   * **ERRO / TEMPO ESGOTADO**: O bote bate no obstáculo, entra em estado de desaceleração e **perde 1 posição na corrida** em relação aos outros competidores.

---

## 🚀 3. Minijogo 2: Foguete de Madeira (Da Floresta ao Espaço)

### 3.1 Visão Geral
O urso construiu um foguete de madeira para alcançar o topo do céu, mas o combustível é **mel**. Durante a subida, ele precisa fugir das abelhas irritadas e manter o foguete abastecido.

### 3.2 Transição de Ambientes & Inimigos
* **Camada 1 — Floresta e Atmosfera**:
  * Fundo de floresta subindo para céu azul.
  * **Inimigos**: Abelhas zangadas terrestres voando em padrões fixos.
* **Camada 2 — Estratosfera e Espaço**:
  * Fundo escuro com estrelas e planetas.
  * **Inimigos**: Abelhas alienígenas mais ágeis, com capacetes espaciais e padrões de ataque em espiral.

### 3.3 Mecânica de Combustível & HUD da Abelha Sábia
1. **Consumo Continuo**: A barra de mel (localizada na HUD) diminui progressivamente. Se esvaziar totalmente, o foguete perde força e cai (Game Over).
2. **Coleta de Mel**: Potes de mel flutuam durante a subida.
3. **Intervenção Educativa (HUD Abelha Sábia)**:
   * Ao tocar em um Pote de Mel, o jogo abre o balão de fala da **Abelha Sábia** (uma abelha professora com óculos).
   * **ACERTO**: Reabastece completamente o medidor de mel e ativa um propulsor *Turbo* temporário (foguete fica invulnerável por alguns segundos).
   * **ERRO**: O pote de mel é perdido, a barra de mel continua diminuindo e o foguete sofre uma pequena perda de combustível extra pelo susto.