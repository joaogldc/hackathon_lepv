# Observatório e Foguete de Madeira — 03/11/2026

## Como jogar

Entre no Observatório pela saída de ciências na praça ou pelo mapa. A entrada abre uma clareira explorável. WASD/setas movem o urso e E interage com o ponto próximo. O círculo DECOLAR abre a preparação do voo; Abelha Sábia explica o combustível e o telescópio apresenta uma descoberta de astronomia. Esc volta à praça; a seta inferior também serve de saída.

Na preparação, escolha o ano escolar e Começar aventura. Pilote com WASD/setas, recolha potes de mel e desvie de abelhas. Um pote abre uma pergunta de ciências: acertar enche o tanque e concede turbo com proteção temporária; errar perde mel. O voo passa da atmosfera para o espaço, onde as abelhas usam capacetes. Tanque vazio encerra a tentativa. O resultado permite revisar os erros e tentar novamente. Voltar/Esc no voo retorna à clareira.

O servidor simula movimento, colisões, combustível, tempo e recompensas. Acertos contam para as missões; chegar à órbita com pelo menos dois acertos conta para science_complete. A conclusão concede dez moedas, uma vez por tentativa. O habitat segue o modelo dos interiores individuais: a posição do urso na clareira é local; salas, perfil e progresso continuam ligados ao servidor.

## Artes

Todos os grupos da folha foguete_abelhas_mel_v1.png são consumidos: quatro quadros normais e quatro de turbo; duas poses de abelha terrestre e duas de abelha espacial; Abelha Sábia; potes cheio, médio e vazio na HUD; quatro quadros do mel coletável. Os cenários de atmosfera e órbita são os arquivos existentes recuperados da demo.

A nova clareira foi gerada pela ferramenta integrada image_gen a partir da região superior direita de assets/ui/mapa/ilha-ursos-3d.png, preservando foguete de madeira, pinheiros, cercas e observatório numa elevação. Arte e prompt completo em assets/cenario/observatorio/. O mapa original não foi substituído.

## Validação

observatory_smoke verifica a navegação real praça/ciências, os três pontos de interação, diálogo, decolagem, gasto de combustível, pote/pergunta, proteção e turbo, resposta duplicada, colisão de abelha, tanque vazio, recompensa única, missão de ciências, retorno à clareira e à praça e escala numa janela de 960 × 600. Capturas de atmosfera, órbita, perguntas e habitat foram inspecionadas. Perfil e porta isolados dos dados reais. Não foi realizada uma sessão com dois computadores nesta entrega.
