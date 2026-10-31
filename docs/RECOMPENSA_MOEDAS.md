# Animação de moedas

Cena: `scenes/ui/recompensa_moedas.tscn`. Usa o urso existente, moedas vetoriais em arco, brilhos, bolsa com impacto e contador progressivo. Adapta a escala à janela. Não pausa a árvore nem a conexão multiplayer.

## Alterar o valor pelo editor

1. Abra `scenes/ui/recompensa_moedas.tscn` no Godot.
2. Selecione o nó raiz **RecompensaMoedas**.
3. No Inspetor, em **Recompensa**, altere **Quantidade Moedas** e salve. O padrão é 25.
4. Aperte **F6** para assistir. Na seção **Animação**, ajuste **Duracao Animacao**, **Reproduzir Ao Iniciar** e **Permitir Pular**.

A instância em `scenes/world/lobby.tscn` tem **Reproduzir Ao Iniciar** desativado. Ela herda o valor da cena original. Também é possível selecionar **RecompensaMoedas** dentro do lobby e sobrescrever **Quantidade Moedas** somente nessa instância.

## Usar em um minigame

Instancie a cena como filha da cena principal e deixe a reprodução automática desativada:

```gdscript
# Usa a quantidade configurada no Inspetor:
$RecompensaMoedas.mostrar()

# Exibe uma recompensa específica, sem modificar a configuração da cena:
$RecompensaMoedas.mostrar(80, "Lia")
```

Zero é aceito. A animação usa uma quantidade limitada de sprites, mesmo com valores grandes; o contador termina no valor solicitado. O primeiro clique em **Pular animação** revela o total, e **Continuar** fecha o painel. Esc faz a mesma ação. `animacao_concluida(valor)` é emitido uma vez por apresentação concluída; `fechada` avisa quando o painel fecha. Reabrir cancela a animação anterior.

## Integração atual

O resultado validado por `Duel` abre a animação somente para o vencedor, incluindo vitória por abandono. Derrota e empate mantêm os avisos existentes. O evento de resultado já possui proteção contra repetição em `Duel`; a animação não cria um segundo resultado. Movimento e atalhos de viagem ficam suspensos localmente durante o painel. Desconectar fecha o efeito.

Esta entrega apresenta a recompensa; não cria carteira, saldo persistente, loja nem novas regras de pagamento. Ao implementar a economia, o servidor deve validar e registrar a recompensa uma única vez e informar o valor a `mostrar(valor)`. Não use o encerramento ou a repetição visual como autorização para creditar moedas.

## Verificação

- `tests/reward_smoke.tscn`: valor configurável, zero, valor por chamada, pular sem conclusão duplicada, reabertura e painel apenas na vitória.
- Regressões em dois processos do duelo e três processos dos espectadores.
- Prévia renderizada pelo Godot com os sprites existentes.
