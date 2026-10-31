# Entrega de MundoDosUrsos3, HUD de quests e Porto Glacial

## Arquivos recebidos

A pasta `MundoDosUrsos3` foi conferida contra o ZIP enviado: os 150 arquivos eram idênticos. O projeto original completo foi preservado em `artwork/MundoDosUrsos3/`, separado do projeto multiplayer.

As versões novas dos sprites e dos arquivos de arte foram consolidadas em `assets/`, incluindo food truck, mesas de bistrô, interiores de cosméticos e pets, provador, quadros de sentar do urso e fontes do Inkscape. A composição visual da área comercial recebeu o food truck, as mesas e os novos posicionamentos. As colisões do servidor foram ajustadas às bases desses objetos.

O projeto principal, suas configurações, autoloads, scripts de rede, duelo, espectadores e pet foram preservados. Os novos interiores, espelho e comportamentos de sentar permanecem disponíveis no projeto artístico independente; ativá-los como áreas de rede é uma etapa própria, não parte do envio de arquivos.

## HUD e sprites gerados por IA

- HUD de quests: `assets/ui/quests/mapa-de-descobertas.png`.
- Chão, cenários e elementos separados: `assets/cenario/glacial_ia/`.
- Kit completo, prompts, prévia no navegador e projeto de montagem: `artwork/porto-glacial-ia/`.

O rótulo da placa do mapa passou de **Bosque do Saber** para **Bosque da Sabedoria**. Os outros textos, estados das quests, nível, XP, enquadramento e elementos visuais foram mantidos. Os demais sprites gerados foram copiados sem edições.

O mapa é uma proposta visual: não introduz novas regras de quests ou de XP no servidor. Os demais HUDs aprovados continuam disponíveis na pasta `docs/hud/revisao-02/` e nos assets existentes.

## Como conferir

1. Abra o projeto principal para jogar a versão multiplayer com a nova arte comercial.
2. Para revisar todas as cenas locais enviadas, abra o `project.godot` de `artwork/MundoDosUrsos3/` como projeto separado.
3. Para revisar o kit de IA, abra `artwork/porto-glacial-ia/PREVIA.html`, ou seu projeto independente no Godot. Na montagem, M alterna o mapa.

`artwork/.gdignore` evita que classes e recursos dos projetos independentes interfiram na importação do jogo principal.
