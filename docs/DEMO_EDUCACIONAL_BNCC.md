# Demo educacional por ano — para validação no outro PC

Branch: `demo_educacional_bncc`. Godot 4.7.2, GDScript.

## Abrir

1. Baixe ou clone **esta branch**, preservando as pastas do projeto.
2. Importe o `project.godot` da raiz e aguarde a importação.
3. Execute com F5 e clique em **Trilhas [F2]** na entrada. Não precisa criar sala.
4. Dentro do mundo, use **F2** ou **Trilhas por ano** na HUD.
5. Alternativamente, abra `scenes/education/demo_educacional.tscn` e use F6.

Esta entrega foi criada sem executar o Godot ou testes locais, conforme pedido.
O roteiro abaixo deve ser executado no computador de validação.

## Referência curricular

Fonte primária: [BNCC oficial — MEC](https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf),
consultada em 31/10/2026. A BNCC orienta os currículos das redes; não é uma
sequência única de aulas. A distribuição das trilhas é uma proposta do jogo.
Em Português, preservamos as faixas de anos dos códigos compartilhados.

| Ano | Matemática | Português | Ciências |
|---|---|---|---|
| 1º | Juntar/retirar · EF01MA08 | Leitura explícita · EF15LP03 | Materiais · EF01CI01 |
| 2º | Adição/subtração · EF02MA06 | Leitura explícita · EF15LP03 | Objetos · EF02CI01 |
| 3º | Grupos · EF03MA07; figuras · EF03MA15 | Ideia central · EF35LP03 | Animais · EF03CI04 |
| 4º | Divisão · EF04MA07 | Inferências · EF35LP04 | Cadeias alimentares · EF04CI04 |
| 5º | Porcentagens · EF05MA06; equivalência · EF05MA04 | Vocabulário contextual · EF35LP05 | Ciclo hidrológico · EF05CI02 |
| 6º | Decimais · EF06MA11 | Fato/opinião · EF67LP04 | Misturas · EF06CI01 |
| 7º | Equações · EF07MA18 | Argumentos · EF67LP05 | Efeito estufa · EF07CI13 |
| 8º | Expressões · EF08MA06; estatística · EF08MA25 | Contra-argumentos · EF89LP04 | Energia · EF08CI03 |
| 9º | Funções · EF09MA06 | Persuasão · EF89LP06 | Partículas · EF09CI01 |

Os códigos foram conferidos no documento oficial. Cada atividade é um exemplo
autoral de prática de aspectos da habilidade, sem cobri-la integralmente.
As questões não são do MEC, e a demo não constitui uma certificação curricular.
Antes de uso com turmas, revisar linguagem, acessibilidade, conteúdo e adequação
ao currículo local com os educadores responsáveis.

## Como a prática funciona

- Seleção livre do 1º ao 9º ano e do componente.
- Explicação inicial, três situações por trilha, alternativas embaralhadas,
  dicas e explicação após cada resposta.
- Ferramenta de contagem nos anos iniciais e espaço para explicar estratégias.
- Revisão direcionada das questões erradas, sem cronômetro ou perda de energia.
- Caderno com rodadas, melhor resultado e uso de dicas. Um acerto não é tratado
  como comprovação de domínio; a revisão não infla a pontuação inicial.

O apoio de leitura de um adulto é previsto para estudantes em alfabetização.
Não há narração automática nesta versão. As práticas são predominantemente
textuais e de múltipla escolha: produção escrita, oralidade, investigação e
atividades corporais precisam de outros formatos e mediação.

## Escopo e próximas integrações

O portal de trilhas é acessível pelo jogo e também funciona sozinho.
Os duelos e desafios anteriores continuam disponíveis com suas regras atuais;
esta demo ainda não troca as perguntas do combate multiplayer por ano.
A seleção de ano vale para as trilhas, não para a fila de adversários.

História, Geografia, Arte, Educação Física, Língua Inglesa e Ensino Religioso
estão identificados no painel de próximos componentes, sem fingir que já
possuem atividades implementadas. Inglês é planejado aqui para o 6º ao 9º.

O caderno fica em `user://education_demo_v1.cfg`, sem nome ou escola. O rascunho
não é salvo. O arquivo é separado de `Progress`: não altera moedas, inventário,
XP ou resultados do multiplayer e não sincroniza automaticamente entre PCs.

## Organização para ampliar

- `resources/education/bncc_lessons.gd`: banco pronto, IDs estáveis, códigos,
  faixa, referência ao PDF, introduções, questões, alternativas e explicações.
- `scripts/education/demo_educacional.gd`: seleção, prática, revisão e caderno.
- `scenes/education/demo_educacional.tscn`: entrada independente.
- `scripts/tools/prepare_education_demo.py`: fonte de autoria do banco; opcional.
  Requer apenas Python para regenerar os dados, não para jogar.

Próximo passo pedagógico: ampliar as unidades de cada ano, oferecer formas
variadas de expressão e observar estratégias. Depois, integrar trilhas ao
mapa da ilha e definir a seleção de conteúdo do duelo no servidor.

## Roteiro para o PC de validação

- Abrir sem rede por F2 e por F6; conferir as nove escolhas de ano.
- Conferir as 30 trilhas e o total de 90 questões, incluindo todos os tipos
  de roupa/pet já existentes ao retornar ao mundo.
- Acertar, errar, pedir dica e usar contagem; verificar explicação e revisão.
- Rever erros até acertar; confirmar que o resultado inicial não aumenta.
- Sair e reabrir: conferir caderno, ano selecionado e ausência de rascunho salvo.
- Em uma sala, abrir as trilhas e conferir que o urso local para, a rede continua
  ativa e o retorno ao mundo libera o movimento.
- Conferir telas menores com rolagem, texto longo e fechamento por Esc/F2.
- Pedir revisão dos enunciados por educadores antes de aplicar com estudantes.
