shader_type canvas_item;
uniform float velocidade : hint_range(0.0, 2.0) = 1.0;
uniform float intensidade : hint_range(0.0, 1.0) = 0.65;
uniform bool animar = true;

float elipse(vec2 p, vec2 centro, vec2 raio) {
    return 1.0 - smoothstep(0.65, 1.0, length((p-centro)/raio));
}
float queda(vec2 p, vec2 inicio, vec2 fim, float largura) {
    vec2 eixo = fim-inicio;
    float u = clamp(dot(p-inicio,eixo)/dot(eixo,eixo),0.0,1.0);
    return (1.0-smoothstep(largura*0.4,largura,length(p-inicio-eixo*u))) * smoothstep(0.0,0.12,u) * (1.0-smoothstep(0.88,1.0,u));
}
void fragment() {
    vec2 p = UV;
    float t = TIME * velocidade;
    float forca = animar ? intensidade : 0.0;
    vec4 original = texture(TEXTURE,p);
    float cascatas = queda(p,vec2(0.126,0.518),vec2(0.118,0.596),0.010)
        + queda(p,vec2(0.358,0.443),vec2(0.350,0.485),0.007)
        + queda(p,vec2(0.695,0.430),vec2(0.701,0.482),0.007);
    float fonte = queda(p,vec2(0.511,0.294),vec2(0.511,0.366),0.009);
    float azul = smoothstep(0.08,0.25,original.b-original.r) * smoothstep(0.4,0.7,original.b);
    float borda = max(smoothstep(0.79,0.94,p.y),max(1.0-smoothstep(0.04,0.16,p.x),smoothstep(0.87,0.98,p.x)));
    float mar = azul * borda;
    vec2 uv = p;
    uv.x += sin(p.y*240.0-t*4.0)*0.0018*mar*forca;
    uv.x += sin(p.y*340.0-t*9.0)*0.0020*cascatas*forca;
    uv.y += sin(t*1.4)*0.0008*elipse(p,vec2(0.425,0.755),vec2(0.10,0.105))*forca;
    vec4 cor = texture(TEXTURE,uv);
    float fluxo = pow(max(0.0,sin(p.y*360.0-t*11.0)),7.0);
    cor.rgb += vec3(0.35,0.65,0.75)*fluxo*(cascatas+fonte)*forca*0.42;
    float reflexo = pow(max(0.0,sin(p.x*190.0+p.y*280.0-t*2.0)),24.0);
    cor.rgb += vec3(0.26,0.40,0.43)*reflexo*mar*forca*0.28;
    vec2 lago = (p-vec2(0.513,0.397))/vec2(0.052,0.025);
    float anel = pow(max(0.0,sin(length(lago)*28.0-t*5.0)),12.0) * (1.0-smoothstep(0.7,1.0,length(lago)));
    cor.rgb += vec3(0.20,0.42,0.48)*anel*azul*forca*0.24;
    float luz = elipse(p,vec2(0.416,0.340),vec2(0.016,0.025))
        + elipse(p,vec2(0.438,0.275),vec2(0.016,0.026))
        + elipse(p,vec2(0.600,0.283),vec2(0.016,0.026))
        + elipse(p,vec2(0.610,0.426),vec2(0.016,0.025))
        + elipse(p,vec2(0.410,0.446),vec2(0.016,0.025))
        + elipse(p,vec2(0.607,0.148),vec2(0.014,0.022));
    cor.rgb += vec3(1.0,0.57,0.14)*luz*(0.28+0.18*sin(t*2.1+p.x*21.0))*forca;
    COLOR = vec4(cor.rgb,original.a);
}
