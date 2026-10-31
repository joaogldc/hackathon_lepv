# Conversa 1: Análise de projeto no GitHub

Chat do Claude, 30/10/2026 (17h35). Texto das mensagens; chamadas de ferramenta omitidas.

## Você

Acesse meu github, o projeto que eu estou colaborando do hackaton, analise

## Claude

Vou localizar o repositório do hackathon no seu GitHub e depois analisar o projeto.

*(Ferramentas: busca de repositórios, clone do repositório, leitura do histórico e dos arquivos.)*

Analisei o **joaogldc/hackathon_lepv** (equipe KILINGOS). Resumo: a organização está boa, mas o repositório ainda **não tem código e o desafio ainda não foi escolhido**. Faltam cerca de 19 horas para o prazo de sábado às 13h.

### Situação atual

- **4 commits, todos de hoje e todos do Lopes**, feitos entre 15h52 e 16h49. Até agora só há documentação: README, `.gitignore` e 5 arquivos em `docs/`.
- `DESAFIOS_EDUCACAO.md` está completo e bem feito: as 5 frentes, as perguntas do slide, a "leitura da equipe" separada do que é oficial e uma tabela para escolher entre as frentes.
- `ENTREGAS_AVALIACAO.md` traduz bem os critérios em tarefas e checklist.
- `PLANO.md` e `DECISOES.md` estão vazios. Não há problema, público, tecnologia nem tarefas definidas.
- O `.gitignore` já protege `.env`, chaves e dependências. Bom sinal.

### O que mais importa na avaliação

1. **O pilar Tech é avaliado por um agente de IA.** Na prática, o repositório é a prova. O agente vai ler o README, a estrutura do código e o `USO_IA.md`. Um README que explique como rodar e um registro de uso de IA honesto valem pontos reais.
2. **Nota abaixo de 1,0 em qualquer pilar elimina a equipe.** Não dá para ter um app ótimo e um plano de negócio fraco, nem o contrário.
3. **A fase 1 exige muito material:** app publicado, vídeo de até 5 minutos, plano de negócio em PDF, slides de até 20 MB e descrição de até 500 caracteres. O plano da equipe precisa reservar várias horas para isso, não só para o código.
4. **Os dados da palestra ainda não foram verificados.** O próprio doc avisa isso. Se forem para o pitch, alguém (pelo README, o Pontes) precisa achar as fontes antes.

### Problemas concretos no repositório

- **A sintaxe do Obsidian não funciona no GitHub.** Os links `[[PLANO]]` e `[[#1. Inclusão e acessibilidade]]` aparecem como texto puro. Os callouts `[!abstract]`, `[!quote]` e `[!info]` também não são reconhecidos. O GitHub só aceita `NOTE`, `TIP`, `IMPORTANT`, `WARNING` e `CAUTION`. Para quem avalia pelo GitHub, incluindo o agente de IA, isso parece pouco cuidadoso. Vale converter para links Markdown normais (`[PLANO](PLANO.md)`) e callouts compatíveis.
- **Só o Lopes aparece no histórico.** Se a banca olhar os commits para avaliar o "domínio do time", ajuda se cada pessoa fizer commits da própria parte.

### Sugestões para a sua parte (estrutura técnica e publicação)

- **Deixe o deploy pronto antes de a ideia fechar.** Escolha uma stack que publique em minutos, por exemplo Vite/Next.js na Vercel ou Streamlit Cloud se for Python. Publique um "hello world" já hoje. Assim a publicação não vira um risco às 12h de sábado.
- **Peça à equipe que decida a frente ainda hoje à noite** e registre a escolha em `DECISOES.md`. As frentes **5 (diagnóstico)** e **3 (adoção saudável de IA)** costumam render uma demo de fluxo único mais fácil de mostrar em 5 minutos, por exemplo: o aluno responde, a IA diagnostica, aparece uma recomendação. A escolha, claro, é do time.
- **Defina como guardar chaves de API** com um `.env.example` e variáveis de ambiente no serviço de deploy. Assim nenhuma chave vai parar no repositório público.

Uma limitação: daqui eu só consigo ler o repositório, não fazer push. Se quiser, preparo os arquivos iniciais da aplicação (estrutura, README de execução, `.env.example`) e as correções de Markdown para você subir, ou anexo o repo com permissão de escrita.
