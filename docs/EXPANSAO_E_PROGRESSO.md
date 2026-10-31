# Áreas, companheiros e progressão — 31/10/2026

## Jogar

Importe `project.godot` no Godot 4.7.2. Crie uma sala e conecte outra instância
para testar a sincronização. Use apelidos diferentes ao simular jogadores no
mesmo computador.

- **M:** viagem livre entre as regiões.
- **Q:** diário com a nova HUD; **Mapa da história** abre as 12 missões. Esc fecha.
- **P:** passaporte com resultados e regiões descobertas salvos.
- **B / botão Pet:** abrir as oito expressões do companheiro; **1 a 8** ativam
  diretamente no mundo. As expressões do peixe e do papagaio vêm das imagens
  originais e aparecem para todos durante 3,5 segundos.
- **Espaço:** sentar/levantar perto de bancos, cadeiras do comércio e pufes.
  Movimentar-se também levanta. Cada assento recebe apenas um jogador.
- As portas continuam automáticas por aproximação; não exigem E.
- **E perto do comerciante da loja de pets:** conversar e escolher peixe ou papagaio. O peixe é inicial; o papagaio custa 140 moedas. Compra e equipamento são salvos e sincronizados.
- **E perto do comerciante de cosméticos ou no provador:** experimentar cartola,
  laço rosa e lenços vermelho/azul, ou remover o acessório.
  O espelho acompanha posição, direção e aparência do jogador local.
- **E perto do mamute ou do lago com fóssil:** investigar e registrar a descoberta.

## Áreas integradas

A nova composição comercial contém food truck, mesas com guarda-sol e colisões
nas bases. Aproxime-se da porta da loja de pets ou de cosméticos para entrar.
Na loja de cosméticos, a seta ao fundo à direita leva ao provador. O puff central
foi removido; o puff lateral do provador permanece. O espelho e as cortinas
têm colisão; as cortinas também têm uma camada visual na frente do jogador.
O urso aparece em escala 2,4 no provador e anda a 456 unidades/s, mantendo a
proporção com as 190 unidades/s das outras áreas. O reflexo é renderizado em
um SubViewport independente e recortado pelos limites do vidro.
A saída de
baixo retorna à loja e depois ao comércio.

Porto Glacial é uma área compartilhada caminhável, com objetos separados,
profundidade, colisões e saída para a praça. O navio, ampliado em 30%, abre uma
expedição de leitura/interpretação. A gruta é decorativa, sem seta nem entrada
ativa. O Observatório abre um desafio de ciências. Cada
expedição contém três perguntas; dois acertos concluem o desafio. Essas são
atividades curtas já jogáveis, não a mecânica planejada de pilotar barco/foguete.

As artes originais permanecem em `artwork/` e `assets/cenario/glacial_ia/`.
O jogo usa versões menores em `glacial_runtime`, preparadas sem gerar imagens
novas. Layouts, pivôs e posições vieram das cenas entregues. O papagaio foi
recortado da imagem enviada; o tabuleiro quadriculado foi removido dos recortes.

## História: 12 missões

1. Visitar o Bosque da Sabedoria.
2. Entrar no dojo.
3. Acertar três defesas de matemática.
4. Vencer um duelo completo.
5. Visitar o Porto Glacial.
6. Investigar o mamute.
7. Investigar o lago com fóssil.
8. Concluir a expedição de leitura do navio.
9. Visitar o Observatório.
10. Acertar uma pergunta de ciências.
11. Acertar três perguntas de ciências.
12. Concluir o desafio do Observatório.

As missões desbloqueiam em sequência e dão XP automaticamente uma única vez.
Ações já realizadas são aproveitadas ao desbloquear a próxima missão. As regiões
continuam livres para explorar; os bloqueios valem para os nós da história.
A cada 100 XP o jogador sobe um nível, começando no nível 1.

O mapa fornecido contém progresso ilustrativo embutido. A interface substitui
o trajeto, nós, missão selecionada, nível e XP por componentes com dados reais.

## Diárias e sequência

Três objetivos: visitar três regiões (20 XP), acertar cinco perguntas (30 XP) e
concluir um duelo (30 XP). Concluir as três concede mais 50 XP e conta um dia
na sequência. Repetir o objetivo no mesmo dia não repete o prêmio.

O dia é definido pelo relógio **UTC do servidor**. Completar também no dia
seguinte estende a sequência. Passar um dia sem completar as três reinicia a
sequência atual; o recorde fica salvo. A virada é verificada mesmo com a sala
aberta. Abandono concede o resultado do duelo, mas não dá XP de conclusão/vitória
para a história nem conta como duelo concluído nas diárias.

## Salvamento e rede

O servidor mantém `user://progress_v1.json`: história, XP, diárias, sequência,
resultados, moedas, pet e acessório. Cada vitória em duelo, incluindo abandono,
concede 25 moedas; o servidor credita apenas uma vez por partida. A animação do
Kilim usa o valor confirmado no resultado. Pular, fechar ou repetir sua exibição
não altera o saldo. As dez roupas, cartola, laço e papagaio são comprados no balcão com débito
validado pelo servidor; o provador permite uma prévia sem comprar.
A instalação do cliente tem um identificador aleatório
em `user://identity.cfg`; perfil é identificado por ele e pelo apelido. Reentrar
no mesmo servidor com o mesmo apelido restaura os dados. Não há conta em nuvem
ou compartilhamento de progresso entre servidores independentes.

O servidor valida portas, assentos, equipamentos, respostas e recompensas.
Clientes não enviam XP ou progresso arbitrário. Respostas corretas não entram
nos snapshots das perguntas. O provador reflete apenas o jogador local; os
outros visitantes e seus equipamentos aparecem normalmente na sala.

## Verificação

- `tests/progression_smoke.gd`: 12 missões, XP único, diárias, dias consecutivos,
  falta de um dia e dados serializados para salvamento.
- `tests/expansion_smoke.tscn`: dois processos WebSocket, portas, interiores,
  troca de pet enviada pelo cliente, estado sentado, reserva exclusiva, roupa,
  descobertas, perguntas privadas e conclusão das atividades.
- Regressões `duel_smoke` (dois processos) e `classroom_smoke` (três processos):
  duelo completo, revanche, quatro formas de abandono e permissões da plateia.
- Importação/inicialização no Godot 4.7.2 e inspeção das áreas, espelho, história,
  diárias e desafio de ciências renderizados.
- `polish_smoke`: proximidade do comerciante no cliente/servidor, acessórios,
  remoção do puff, colisão do espelho/cortinas, gruta inativa, estados circulares
  de missões e moedas creditadas/salvas uma vez por partida.
- `reward_smoke`: quantidade, zero, substituição do valor, pular, reabrir e Esc.
- `pet_emotes_smoke.tscn`: dois processos na porta 19105; reações nos dois
  sentidos, expiração, rejeição de valores inválidos, intervalo entre reações
  e velocidade proporcional exclusiva do provador. O segundo processo usa
  `-- --client`.

Testes de rede usam portas 19081 e 19094, sem ocupar a porta normal 9080.

A revisão da HUD, compras e primeiro selo está detalhada em `HUD_PRINCIPAL.md`.
