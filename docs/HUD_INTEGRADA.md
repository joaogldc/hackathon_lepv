# Integração visual — HUD revisão 02

Analisadas antes da edição as cinco telas de `docs/hud/revisao-02`, o atlas de
cartas e `hud-cartas.png`. Atualizado o remoto até `7f6d6df`. Os arquivos de arte
originais foram preservados. Um conflito de integração em world_geometry.gd foi
resolvido mantendo as colisões locais do bosque/arbustos e as novas do comércio.

## Duelo

- Três painéis compactos de energia, fase/turno e tempo, nas cores da referência.
- Painel central removido durante a escolha de carta. O fundo da sala de aula e
  os espectadores continuam visíveis; o livro/púlpito não invade mais a interface.
- Cartas usam o atlas enviado, com leque discreto, seleção elevada e borda dourada.
- Selecionar uma carta não a joga imediatamente; confirmar em **Jogar carta**.
- Alternativas selecionáveis e botão **Confirmar** antes de enviar a resposta.
- Pergunta e resultado usam painéis claros. As regras continuam em Duel.
- Os números do mockup eram ilustrativos: os componentes agora mostram os dados
  reais, 5 de energia e 1 de dano para qualquer dificuldade.

## Mundo e passaporte

A HUD de conexão fica visível até entrar na sala. Depois ela dá lugar ao perfil
compacto, nome da área, prévia da região e botões de mapa e passaporte. P abre o
passaporte; M continua abrindo o mapa da ilha. O passaporte mostra regiões visitadas
e resultados reais da sessão, e permite viajar às três regiões educativas.
Não exibe nível, moedas, selos ou ações sociais fictícias das imagens de referência.
Esses dados ainda não são persistidos após fechar o projeto. A arte comercial e
as vitrines recebidas também estão integradas.

## Verificações

Godot 4.7.2: importação sem erros, renderização de mundo, passaporte, comércio,
cartas, pergunta e resultado. Capturas inspecionadas e corrigidos os tamanhos
mínimos do retrato e das barras de energia. Testado que selecionar carta aguarda
confirmação e que o envio abre a pergunta. `duel_smoke`: dez turnos, vencedor,
revanche e desconexão, código 0 nos dois processos. `classroom_smoke`: abandono
pelo botão, mapa, anfitrião saindo do dojo e visitante desconectando, além de
permissões de espectador; código 0 nos três processos.
