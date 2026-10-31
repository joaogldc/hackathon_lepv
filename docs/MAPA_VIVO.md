# Mapa vivo

O mapa da ilha agora tem água correndo nas três quedas, movimento na fonte, reflexos no mar, brilho suave nas lanternas e balanço discreto no navio. A animação é executada por um shader no Godot, sobre a ilustração original. Não é um vídeo nem altera as regiões clicáveis.

Abra `scenes/ui/mapa_ilha.tscn` e selecione a raiz. No Inspetor, **Mapa vivo** permite ligar/desligar a animação, ajustar a velocidade e a intensidade. A velocidade zero congela os efeitos; desligar a animação mostra a imagem original. O padrão usa luzes suaves, sem flashes rápidos.

O shader fica em `assets/ui/mapa/mapa_vivo.gdshader`. As áreas de água e luz são coordenadas proporcionais desta ilustração; ao trocar o desenho, ajuste essas máscaras. O minimapa pequeno permanece estático para manter a leitura.
