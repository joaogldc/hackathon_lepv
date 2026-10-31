# Sala de aula: resultados, espectadores e entradas

## Testar

Recarregar o projeto e executar duas instâncias para jogar. Uma terceira instância
pode entrar no dojo e clicar em **Assistir sentado**. O servidor reserva um dos
8 assentos, mostra o urso sentado à mesa e envia as atualizações da partida.
**Levantar** encerra a observação. O espectador não pode atacar nem responder.
Quem começa assistindo antes da partida acompanha o próximo duelo; após o fim,
pode continuar assistindo uma nova partida ou entrar na fila para jogar.

Durante uma partida, testar **Sair do dojo**, Esc, viajar pelo mapa e desconectar
o visitante. A conta que permanece recebe **Vitória!** com o motivo do abandono.
O resultado da partida e o aviso são independentes da cena do jogador que saiu.
O aviso permanece até ser reconhecido. O servidor registra a saída antes de mudar
a área ou remover o jogador. O resultado é entregue uma única vez por partida.
Vitórias, derrotas e moedas ainda não são persistidas entre sessões.

Fechar o aplicativo que está hospedando encerra o servidor: a outra conta recebe
aviso de desconexão, pois não há mais servidor para emitir resultado. Para manter
partidas nesse caso é necessário executar o servidor dedicado separadamente.

## Transições

As passagens físicas entre praça e bosque agora conectam esquerda/direita;
entre praça e comércio conectam norte/sul. O urso chega pela borda correspondente,
preserva a coordenada lateral e caminha para dentro durante 260 ms. Uma transição
visual curta acompanha a troca. O retorno do dojo posiciona o urso junto à porta.
Isso substitui a chegada ao centro da sala. O mapa mantém a viagem direta,
conforme solicitado anteriormente.

O bosque é caminhável. Passar pela seta na porta leva ao dojo; sair do dojo volta
para fora da porta. A colisão da fonte continua sendo validada pelo servidor.

## Artes integradas

Atualização de origin/main em `e3c8d74`:

- Bosque: chão, dois tipos de bambuzal, dojo, cercas, lanternas e tsukubai.
- Sala de aula: fundo com quadro e almofadas, mesas baixas, estante, púlpito e taiko.
- Espectadores: pose `N_sit` do urso nas mesas laterais.
- Praça: artes atualizadas e placas direcionais para as quatro áreas.

Não havia arte de passaporte no remoto; o usuário confirmou que ainda não foi
enviada. A implementação do passaporte fica aguardando essa definição.

## Verificações executadas no Godot 4.7.2

- `classroom_smoke`: três processos reais, dois duelistas e um espectador; vitória
  por saída pelo botão, saída pelo mapa, saída do anfitrião do dojo e desconexão
  do visitante. Resultado também recebido na outra conta, sem expor a resposta
  correta ao espectador; comandos de ataque/resposta do espectador rejeitados.
  Os três processos encerraram com código 0 e sem erros de script.
- `duel_smoke`: dez turnos completos, dano, vencedor, revanche e desconexão;
  código 0 no servidor e no cliente.
- Renderização e inspeção visual do bosque e da sala de aula com plateia sentada.
- Chegada física pela borda e caminhada de entrada verificadas em execução.

A primeira versão do teste presumiu a ordem dos jogadores e falhou; a expectativa
foi corrigida para usar os IDs reais da partida. O teste também identificou avisos
modais sobrepostos, corrigidos usando uma única janela de resultado reutilizável.

Executar o teste em três terminais (porta 9080 livre):

```powershell
godot --headless --path . res://tests/classroom_smoke.tscn -- --role=host
godot --headless --path . res://tests/classroom_smoke.tscn -- --role=fighter
godot --headless --path . res://tests/classroom_smoke.tscn -- --role=spectator
```

## Ajustes após as capturas do usuário

- HUD do dojo reduzida, com escala proporcional e centralização para diferentes
  tamanhos de viewport. Placar, ursos, painel central e leque ocupam menos espaço.
- Setas amarelas com contorno claro, sombra e projeção achatada no plano do chão.
  Na praça ficam no centro das estradas; placas foram deslocadas para a grama.
- Saídas ativadas por corredores próximos à borda, sem contato obrigatório com
  a seta. A mesma regra é validada no servidor.
- Entrada do bosque pela parte inferior do caminho, com caminhada para dentro.
  Saída para a praça também fica na parte inferior.
- Bambuzais e lanternas possuem colisão nas bases, com margem para os pés do urso.
- Host aceita porta opcional para testes isolados. Os testes de dojo e sala de aula
  usam 19081, evitando interferir na sala de jogo aberta na porta padrão 9080.

Verificado no Godot 4.7.2: chegada inferior, ativação de saída antes da seta,
cinco bases de obstáculos, entrada no dojo e renderização em 1152×720 e 960×600.
Capturas inspecionadas visualmente. Teste de três processos repetido: desistência
pelo botão, mapa, saída do anfitrião do dojo e desconexão, além de permissões dos
espectadores; todos encerraram com código 0.

## Alinhamento das mesas e ordem de desenho

As oito posições de espectadores agora seguem os centros das almofadas pintadas
no fundo da sala: quatro na primeira fileira e duas nas laterais de cada uma das
duas fileiras seguintes. As mesas ficam à frente dos espectadores, com dimensões
menores. Os duelistas foram elevados para o palco, liberando a primeira fileira.

Os móveis (incluindo o púlpito com livro) são desenhados antes dos painéis da HUD.
O painel central é opaco para impedir que livro e cenário interfiram no texto.
Verificado no Godot 4.7.2 com oito espectadores simulados, captura renderizada e
inspecionada visualmente. A seleção de assentos do servidor permanece a mesma.

## Cercas, fundo do bosque, arbustos e apelidos

Adicionadas colisões nas duas cercas do bosque, na faixa de bambus ao fundo e
nos quatro arbustos da praça. A colisão continua autoritativa no servidor e usa
subpassos para bloquear travessias. Spawn e recuperação de posições inválidas
agora procuram o ponto livre mais próximo, inclusive perto dos arbustos.

O retorno do dojo usa o ponto (560, 500), sobre a pedra central do caminho, sem
a caminhada automática que o deslocava ao reaparecer. Textos soltos das setas
do bosque e do comércio removidos. Apelidos dos ursos e espectadores usam amarelo
com contorno azul-escuro para leitura em fundos claros e escuros.

Verificado no Godot 4.7.2: bloqueio e recuperação de posição em cercas, bambus do
fundo e arbustos; retorno ao caminho após sair do dojo. Capturas da praça e do
retorno ao bosque renderizadas e inspecionadas visualmente. Código 0 no teste.

Correção adicional do retorno bosque → praça: a altura antiga era 425, acima da
estrada. A chegada agora usa a mesma altura da seta oeste (460). Teste executado
no Godot: retorno e movimento de entrada mantêm os pés no centro da estrada;
captura inspecionada visualmente e código 0.

Spawn inicial: substituída a grade que começava junto ao arbusto por oito posições
no piso pavimentado, abaixo da fonte. Cada conexão recebe um slot livre para
não repetir posições após desconexões. Verificados oito pontos distintos sem
colisão e captura do primeiro jogador inspecionada no Godot 4.7.2; código 0.
