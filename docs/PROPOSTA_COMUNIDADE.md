---
title: Proposta — comunidade de aprendizagem
data: 2026-10-30
status: hipótese em discussão
tags: [produto, engajamento, personalizacao]
---

# Proposta — comunidade de aprendizagem

## Ideias trazidas pela equipe

- Atuar em engajamento e aprendizagem individualizada: desafios 2 e 4.
- Buscar mudança cultural: tornar aprender algo valorizado entre os alunos.
- Personalização e gamificação isoladas não garantem engajamento.
- Inspiração no Strava: reconhecimento, competição e pertencimento.
- Explorar ranking e premiação; entender quem paga e como sustentar o produto.
- Avaliar IA para adaptação e banco de dados para histórico de aprendizagem.

Esses pontos expressam a hipótese da equipe; não constituem validação de impacto ou descrição comprovada de outras plataformas.

## Direção recomendada — ainda não decidida

**Uma comunidade escolar em que cada aluno enfrenta desafios adequados ao seu nível e contribui para conquistas coletivas com sua própria evolução.**

O produto conecta duas necessidades: ter um motivo social para voltar e receber uma atividade apropriada quando voltar.

### Reconhecimento e competição

- Progresso individual fica visível ao próprio aluno e ao professor.
- Equipes da turma avançam por metas de aprendizagem, com contribuição individual limitada por período.
- Testar temporadas curtas e reconhecimento de evolução, constância e colaboração.
- Evitar depender de classificação por nota absoluta: quem começa sabendo mais pode dominar sem evoluir.
- Pontos por aprendizagem demonstrada em novas questões; tempo de tela e quantidade de cliques não comprovam domínio.
- Premiação pode começar com reconhecimento e experiências definidas pela escola. Prêmios materiais são hipótese posterior, com orçamento próprio.

Riscos a testar: desmotivação de quem fica atrás, trapaça, comparação injusta entre tarefas e participação apenas pelo prêmio. Não afirmar que a mecânica muda a cultura antes de testar.

## Personalização: separar regras, IA e histórico

| Componente | Função no MVP |
| --- | --- |
| Diagnóstico curto | Estimar conhecimentos iniciais por habilidade, sem rotular o aluno. |
| Regras de progressão | Selecionar a próxima atividade a partir das respostas e ajudas usadas. |
| IA | Adaptar a linguagem e o contexto de exemplos; oferecer dicas graduais a partir de conteúdo revisado. |
| Banco de dados | Guardar tentativas, habilidade, ajuda recebida e progresso para retomar o percurso. |

IA não precisa decidir pontuação ou corrigir contas objetivas: respostas e regras verificáveis podem cumprir essas tarefas. Para questões geradas, prever revisão e critérios de validação. A evidência consultada sobre ensino individualizado destaca avaliação das lacunas, atividades adequadas e feedback; ela não valida nosso mecanismo social.

### Dados mínimos

- Identificador fictício do aluno e turma/equipe.
- Habilidade e atividade respondida.
- Resposta, resultado, dicas utilizadas e momento da tentativa.
- Estimativa de domínio por habilidade e histórico de contribuições.
- Preferência opcional de contexto para os exemplos.

Na demonstração, usar alunos fictícios. Um banco local pode persistir um protótipo; uma experiência real com vários usuários exige armazenamento compartilhado e controle de acesso. Não é necessário coletar diagnósticos clínicos, endereço ou um perfil extenso para demonstrar personalização pedagógica.

## Modelo de negócio — hipótese

**Cliente inicial sugerido: escola privada; usuário: aluno e professor.**

- Escola paga assinatura por turma ou aluno ativo.
- Valor a validar: prática recorrente, atividades ajustadas e visão do progresso para o professor.
- Receita precisa cobrir IA, hospedagem, suporte e aquisição de clientes; só a margem restante sustenta lucro e eventuais prêmios.
- Patrocínios podem financiar experiências ou recompensas em uma fase posterior; não depender deles para o primeiro modelo.
- Testar disposição da escola a pagar antes de definir preços.

## Recorte sugerido para o hackathon

Proposta inicial, sujeita à decisão do grupo: uma turma de 6º ano, matemática, comparação e equivalência de frações.

### Fluxo de demonstração

1. Aluno entra numa turma fictícia e escolhe um contexto de interesse.
2. Responde a um diagnóstico curto.
3. Recebe uma atividade adequada ao desempenho observado.
4. Se erra, recebe uma dica e tenta uma questão equivalente.
5. Acerta uma questão nova sem ajuda e registra evidência de progresso.
6. A contribuição atualiza a meta de sua equipe.
7. Professor vê a dificuldade identificada e a evolução observada.

Mostrar dois alunos com pontos de partida diferentes. O número de pontos e a comparabilidade entre percursos ainda precisam de uma regra explícita; normalização simples por evolução é uma hipótese, não garantia de justiça.

## Como validar

- **Engajamento:** retorno em dias diferentes, participação distribuída e atividades concluídas; no hackathon, só demonstramos o registro dessas métricas.
- **Aprendizagem:** questões novas, sem ajuda, antes/depois e posteriormente para verificar retenção.
- **Adoção:** professor entende os resultados e consegue aplicar sem trabalho excessivo?
- **Cultura:** observar ao longo de semanas reconhecimento entre colegas e participação além dos líderes. Não é mensurável numa demo de poucas horas.

## Próximas decisões

- [ ] Escolher faixa etária e habilidade.
- [ ] Definir se o principal mecanismo social será equipe, reconhecimento individual ou ambos.
- [ ] Definir o que conta como progresso e como evitar repetição para acumular pontos.
- [ ] Conversar com professor ou mentor sobre adoção e ranking.
- [ ] Fechar escopo e dividir tarefas em [[PLANO]].

## Referência consultada

[EEF — Individualised instruction](https://educationendowmentfoundation.org.uk/education-evidence/teaching-learning-toolkit/individualised-instruction): avaliação das lacunas, adequação das atividades e feedback como elementos da implementação. Não constitui evidência de eficácia desta proposta específica.

Relacionadas: [[DESAFIOS_EDUCACAO]] · [[ENTREGAS_AVALIACAO]] · [[DECISOES]]
