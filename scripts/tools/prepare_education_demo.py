"""Author the original demonstration bank; not required to run the Godot project."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
SOURCE = 'https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf'
lessons = []

def q(prompt, correct, wrong_a, wrong_b, why, hint, reading=''):
    return dict(prompt=prompt, answers=[str(correct), str(wrong_a), str(wrong_b)], correct=0,
                why=why, hint=hint, reading=reading)

def lesson(grade, subject, title, skill, page, intro, questions, suffix='', band=''):
    lessons.append(dict(id=f'{subject}_{grade}'+suffix, grade=grade, subject=subject,
        title=title, skill=skill, source_page=page+1, source_url=SOURCE,
        band=band or f'{grade}º ano', intro=intro, questions=questions,
        coverage='Recorte de prática; não cobre integralmente a habilidade.'))

lesson(1,'math','Juntar e retirar','EF01MA08',280,
 'Conte com tampinhas, riscos ou dedos. Juntar aumenta uma coleção; retirar diminui. Por exemplo, 2 pedras e mais 1 pedra formam 3 pedras.',[
 q('Cora tem 5 sementes e ganha 3. Quantas tem agora?',8,2,9,'Juntamos 5 + 3: 6, 7, 8 sementes.','Desenhe cinco bolinhas e acrescente três.'),
 q('Havia 9 folhas. O vento levou 4. Quantas ficaram?',5,13,4,'Retirar quatro de nove deixa cinco: 9 − 4 = 5.','Risque quatro de nove marcas.'),
 q('No banco há 6 ursos. Chegam 2. Quantos ficam?',8,4,7,'Chegaram mais dois: 6 + 2 = 8.','Continue a contagem a partir de seis.')])
lesson(2,'math','Contas em situações','EF02MA06',284,
 'Separe centenas, dezenas e unidades. Você pode somar por partes: 120 + 30 = 150. Na subtração, confira somando o que restou ao que foi retirado.',[
 q('A biblioteca tinha 125 livros e recebeu 40. Quantos tem?',165,85,129,'125 + 40 = 165. Foram acrescentadas quatro dezenas.','Some primeiro as dezenas.'),
 q('O viveiro tinha 230 mudas e doou 110. Quantas restaram?',120,340,220,'230 − 110 = 120. Confira: 120 + 110 = 230.','Separe centenas e dezenas.'),
 q('Uma turma recolheu 48 papéis de manhã e 27 à tarde. Qual é o total?',75,65,21,'48 + 20 = 68; 68 + 7 = 75.','Some vinte e depois sete.')])
lesson(3,'math','Grupos iguais','EF03MA07',288,
 'Multiplicar pode organizar grupos com a mesma quantidade. Três caixas com 2 lápis cada representam 2 + 2 + 2 = 6. Desenhe os grupos antes de calcular.',[
 q('Quatro vasos têm 3 flores cada. Quantas flores?',12,7,9,'São quatro grupos de três: 3 + 3 + 3 + 3 = 12.','Conte quatro grupos de três.'),
 q('Cinco bancos têm 2 lugares cada. Quantos lugares?',10,7,12,'Cinco grupos de dois formam dez: 5 × 2 = 10.','Conte de dois em dois cinco vezes.'),
 q('Há 3 filas com 10 sementes em cada fila. Qual é o total?',30,13,20,'As três filas têm a mesma quantidade: 10 + 10 + 10 = 30.','Cada fila acrescenta uma dezena.')])
lesson(4,'math','Repartir e agrupar','EF04MA07',292,
 'Dividir pode repartir igualmente ou descobrir quantos grupos cabem. Se 18 sementes vão para 3 vasos igualmente, cada vaso recebe 6. Confira multiplicando.',[
 q('48 sementes são repartidas igualmente em 6 vasos. Quantas por vaso?',8,6,9,'48 ÷ 6 = 8, pois 6 × 8 = 48.','Procure um número que, multiplicado por seis, resulte em 48.'),
 q('96 livros serão colocados em caixas de 12. Quantas caixas completas?',8,12,9,'96 ÷ 12 = 8 caixas. Aqui procuramos quantos grupos de doze cabem.','Some doze repetidamente ou use a multiplicação.'),
 q('75 adesivos são repartidos igualmente entre 5 ursos. Quantos para cada?',15,10,20,'75 ÷ 5 = 15: cinco grupos de quinze totalizam 75.','Separe 75 em 50 + 25 e divida cada parte por cinco.')])
lesson(5,'math','Porcentagens do cotidiano','EF05MA06',296,
 'Porcentagem compara uma quantidade com cem partes. 50% é metade; 25% é um quarto; 10% é um décimo. De 60 sementes, por exemplo, 50% são 30.',[
 q('Qual é 50% de 80 sementes?',40,50,160,'50% significa metade: 80 ÷ 2 = 40.','Encontre a metade de oitenta.'),
 q('Qual é 25% de 40 páginas?',10,25,20,'25% é um quarto. Divida quarenta em quatro partes iguais: 10.','Um quarto corresponde a uma de quatro partes iguais.'),
 q('Um item de 100 moedas tem desconto de 10%. Qual é o preço final?',90,10,110,'10% de 100 são 10. O desconto reduz o preço: 100 − 10 = 90.','Primeiro calcule o desconto; depois retire-o do preço.')])
lesson(6,'math','Operações com decimais','EF06MA11',302,
 'Nas somas e subtrações, alinhe as casas decimais. Estime antes: 3,20 + 1,90 deve ficar perto de 5. Em situações de preço, explique o resultado com sua unidade.',[
 q('Uma fita mede 2,5 m e outra 1,75 m. Qual é a soma?', '4,25 m','3,25 m','4,75 m','Escreva 2,50 + 1,75 = 4,25 metros.','Complete 2,5 com um zero: 2,50.'),
 q('Uma compra custa 12,60 moedas. O pagamento foi 20,00. Qual é o troco?','7,40','8,60','32,60','20,00 − 12,60 = 7,40. A compra mais o troco recompõe vinte.','Faça a diferença entre pagamento e preço.'),
 q('Quatro cadernos custam 3,50 moedas cada. Qual é o total?','14,00','7,50','12,00','3,50 × 4 = 14,00. São quatro parcelas de 3,50.','Calcule quatro vezes três e quatro vezes meio.')])
lesson(7,'math','Encontrar a incógnita','EF07MA18',308,
 'Uma equação mantém os dois lados iguais. Para resolver 2x + 3 = 11, retire 3 dos dois lados e depois divida ambos por 2. Assim, x = 4. Confira substituindo.',[
 q('Qual valor de x resolve 3x + 5 = 20?',5,15,8,'Retire 5: 3x = 15. Divida por 3: x = 5. Confira 3 × 5 + 5 = 20.','Desfaça primeiro a adição, depois a multiplicação.'),
 q('Qual valor de x resolve 2x − 4 = 10?',7,3,5,'Some 4 aos dois lados: 2x = 14. Divida por 2: x = 7.','A operação inversa de retirar quatro é acrescentar quatro.'),
 q('Três ingressos iguais e uma taxa de 6 moedas custam 30. Qual é o preço de cada ingresso?',8,12,10,'3x + 6 = 30; 3x = 24; x = 8 moedas.','Separe a taxa antes de dividir entre os ingressos.')])
lesson(8,'math','Expressões e substituição','EF08MA06',314,
 'Para calcular uma expressão, substitua a letra pelo valor indicado. Respeite parênteses e potências antes das demais operações. Se x = 3, então x² + 1 = 10.',[
 q('Se x = 4, quanto vale 2x + 3?',11,14,9,'Substitua x por 4: 2 × 4 + 3 = 11.','A multiplicação vem antes da adição.'),
 q('Se a = 3 e b = 2, quanto vale a² − b?',7,1,5,'3² − 2 = 9 − 2 = 7. Elevar ao quadrado não é multiplicar por dois.','Calcule primeiro três ao quadrado.'),
 q('Se x = 5, quanto vale 2(x − 1)?',8,9,4,'Primeiro 5 − 1 = 4; depois 2 × 4 = 8.','Resolva o que está entre parênteses.')])
lesson(9,'math','Relações e funções','EF09MA06',318,
 'Uma função associa cada entrada a uma única saída. Em C(n) = 4n + 2, n pode indicar itens e C o custo: há uma parte variável e uma taxa fixa. Use uma tabela para observar a relação.',[
 q('Em C(n) = 3n + 5, qual é C(4)?',17,12,20,'Substitua n por 4: 3 × 4 + 5 = 17.','A entrada quatro ocupa o lugar de n.'),
 q('Uma tabela tem entradas 1, 2, 3 e saídas 4, 7, 10. Qual regra serve para todas?', 'f(x) = 3x + 1','f(x) = x + 3','f(x) = 4x','3 × 1 + 1 = 4; 3 × 2 + 1 = 7; 3 × 3 + 1 = 10.','Não basta acertar uma linha: confira as três.'),
 q('No registro de uma máquina, a mesma entrada 2 produz 5 e 7 sem nenhuma outra condição. Esse registro define uma função da entrada para a saída?','Não: uma entrada tem duas saídas','Sim: toda tabela define função','Sim: as saídas são positivas','Uma função precisa dar uma única saída para cada entrada. Esse registro viola a condição.','Observe se a saída fica determinada por uma única entrada.')])

lesson(3,'math','Investigar figuras','EF03MA15',290,
 'Observe lados e vértices, não apenas a posição da figura. Girar um quadrado não altera seus quatro lados iguais. Um desenho inclinado continua sendo a mesma figura.',[
 q('Uma figura plana fechada tem três lados retos e três vértices. Qual é?','Triângulo','Quadrado','Círculo','Um triângulo tem três lados e três vértices.','Conte os segmentos retos e seus encontros.'),
 q('O que quadrado e retângulo têm em comum?','Quatro lados e quatro vértices','Sempre quatro lados do mesmo comprimento','Três vértices','Ambos têm quatro lados e quatro vértices. Um retângulo não precisa ter os quatro lados iguais.','Compare características, sem depender do tamanho.'),
 q('Cora girou um quadrado de papel, sem dobrá-lo nem cortá-lo. O que aconteceu com o número de lados?','Continuou quatro','Passou a três','Passou a cinco','A rotação muda a posição, não a quantidade de lados.','Pense no que mudou e no que permaneceu.')],suffix='_figuras')
lesson(5,'math','Frações equivalentes','EF05MA04',296,
 'Frações equivalentes representam a mesma quantidade. Se cada metade é dividida novamente em duas partes, 1/2 passa a ser representada por 2/4. O tamanho do inteiro precisa ser o mesmo.',[
 q('Qual fração é equivalente a 1/2?','2/4','1/4','2/3','Multiplicar numerador e denominador de 1/2 por dois dá 2/4.','Divida cada uma das duas metades em duas partes.'),
 q('Qual fração é equivalente a 3/4?','6/8','3/8','4/6','Multiplique os dois termos por dois: 3/4 = 6/8.','A mesma operação deve atingir numerador e denominador.'),
 q('Do mesmo bolo, Lia comeu 2/6 e Ivo comeu 1/3. Quem comeu mais?','Comeram a mesma quantidade','Lia comeu mais','Ivo comeu mais','Dividindo os dois termos de 2/6 por dois, obtemos 1/3.','Compare as frações usando partes do mesmo inteiro.')],suffix='_fracoes')
lesson(8,'math','Ler dados e calcular','EF08MA25',316,
 'A média soma os valores e divide pela quantidade. A moda é o valor mais frequente. A mediana é o valor central depois de ordenar os dados. Essas medidas respondem a perguntas diferentes.',[
 q('As quantidades de livros lidos foram 2, 4 e 6. Qual é a média?',4,6,12,'A soma é 12; há três valores; 12 ÷ 3 = 4.','Não confunda a soma com a média.'),
 q('Nos dados 1, 2, 2 e 5, qual é a moda?',2,5,1,'O valor dois aparece duas vezes; os demais aparecem uma.','Procure o valor mais frequente.'),
 q('Depois de ordenar os dados 7, 3 e 5, qual é a mediana?',5,3,7,'A ordem é 3, 5, 7. O elemento central é 5.','Ordene antes de procurar o centro.')],suffix='_dados')

texts = [
 (1,'Encontrar no texto','EF15LP03',96,'1º ao 5º ano', 'Leia ou peça a alguém para ler. Volte ao texto para encontrar a informação, em vez de adivinhar.',[
  ('CORA TEM UM LIVRO. O LIVRO É AZUL.','QUAL É A COR DO LIVRO?','AZUL','VERDE','AMARELO','O texto diz que o livro é azul.'),
  ('IVO VIU UM PEIXE NO RIO.','ONDE IVO VIU O PEIXE?','NO RIO','NO DOJO','NO BANCO','A expressão NO RIO conta o lugar.'),
  ('LIA LEVOU UMA MAÇÃ PARA O PASSEIO.','O QUE LIA LEVOU?','UMA MAÇÃ','UM BARCO','UMA BOLA','O objeto levado aparece na frase: UMA MAÇÃ.')]),
 (2,'Ler com atenção','EF15LP03',96,'1º ao 5º ano','Identifique quem participa, o que acontece e onde ou quando. Uma palavra da pergunta pode ajudar a procurar a passagem certa.',[
  ('Na quinta-feira, a turma visitou o porto. Cora levou um caderno para desenhar.','Em que dia aconteceu a visita?','Quinta-feira','Terça-feira','Domingo','O dia aparece no início do texto.'),
  ('Ivo guardou as sementes na caixa verde. A caixa azul ficou vazia.','Em qual caixa ficaram as sementes?','Na verde','Na azul','Em nenhuma','A primeira frase informa onde Ivo as guardou.'),
  ('Lia terminou a leitura e devolveu o livro à biblioteca antes do almoço.','O que Lia devolveu?','O livro','O almoço','Uma semente','Devolveu se refere ao livro que ela havia lido.')]),
 (3,'Compreender o essencial','EF35LP03',114,'3º ao 5º ano','A ideia central liga as informações do texto. Um detalhe pode ser verdadeiro e, mesmo assim, não resumir a mensagem principal.',[
  ('A turma recolheu papéis e separou materiais reutilizáveis. Depois, combinou formas de produzir menos lixo na praça.','Qual é a ideia central?','Cuidar dos resíduos na praça','Comprar cadernos novos','Escolher o banco mais alto','As duas ações tratam dos resíduos e de como reduzi-los.'),
  ('Cora leu os avisos antes da viagem e conferiu os horários. Assim, chegou ao embarque no momento combinado.','Qual é a ideia central?','Planejar ajuda a cumprir horários','Todos os barcos são iguais','Avisos nunca mudam','Ler avisos e conferir horários são ações de planejamento.'),
  ('Os ursos ouviram sugestões diferentes para o jardim. Juntos, escolheram uma proposta que atendia à turma.','Qual é a ideia central?','Construir uma decisão em conjunto','Medir a altura de uma árvore','Pintar todas as flores','Ouvir e escolher juntos formam o núcleo do texto.')]),
 (4,'Investigar pistas','EF35LP04',114,'3º ao 5º ano','Uma inferência combina pistas do texto com conhecimentos pertinentes. Procure evidências e evite acrescentar detalhes que o texto não sustenta.',[
  ('Cora entrou com o guarda-chuva molhado. Lá fora, gotas batiam na janela.','O que é mais provável?','Estava chovendo','Estava nevando dentro do dojo','Cora acabara de nadar','Guarda-chuva molhado e gotas na janela sustentam a inferência de chuva.'),
  ('Ivo procurou o livro em todas as prateleiras. Quando Lia o encontrou, ele sorriu aliviado.','Por que Ivo provavelmente se sentiu aliviado?','Queria encontrar o livro','Queria esconder o livro','Não sabia o que era uma prateleira','A busca e o sorriso ligam o alívio ao encontro do livro.'),
  ('Antes de atravessar a ponte estreita, Lia diminuiu o passo e segurou o corrimão.','Que atitude essas ações sugerem?','Cuidado ao atravessar','Pressa para correr','Vontade de pular na água','Passo mais lento e uso do corrimão indicam cuidado.')]),
 (5,'Palavras em contexto','EF35LP05',114,'3º ao 5º ano','Leia o entorno de uma palavra desconhecida. A situação e as demais expressões ajudam a construir um sentido possível.',[
  ('A água ficou escassa durante a seca: restava muito pouco no reservatório.','Nesse contexto, escassa significa…','Pouca','Abundante','Colorida','Restava muito pouco explica o sentido de escassa.'),
  ('Lia avançou com cautela, observando cada tábua solta da ponte.','Cautela indica…','Cuidado','Distração','Barulho','Observar as tábuas antes de avançar é agir com cuidado.'),
  ('A chuva parou e a turma retomou o passeio, que havia sido interrompido.','Retomou significa…','Continuou novamente','Cancelou para sempre','Esqueceu o caminho','O passeio havia parado; retomar é dar continuidade a ele.')]),
 (6,'Fato e opinião','EF67LP04',164,'6º e 7º anos','Diferencie afirmações verificáveis de avaliações pessoais. Uma afirmação verificável ainda precisa de conferência; parecer um fato não a torna automaticamente verdadeira.',[
  ('O aviso afirma: A biblioteca abre às 8h. Cora comenta: Esse é o melhor horário.','Qual trecho expressa uma opinião?','Esse é o melhor horário','A biblioteca abre às 8h','O aviso está escrito','Melhor é uma avaliação pessoal; o horário pode ser conferido.'),
  ('Ivo escreveu: A ponte mede 12 metros e é a mais bonita da ilha.','Qual informação pode ser conferida por medição?','A ponte mede 12 metros','É a mais bonita','Ivo gosta da ponte','O comprimento pode ser medido. A beleza envolve julgamento.'),
  ('Uma postagem diz: Ontem foram emprestados 20 livros.','Qual é o próximo passo para verificar essa afirmação?','Consultar o registro dos empréstimos','Acreditar porque há um número','Decidir pela cor da postagem','Um número não comprova a afirmação: é preciso conferir a fonte.')]),
 (7,'Posições e razões','EF67LP05',164,'6º e 7º anos','Uma tese expressa a posição defendida. Os argumentos apresentam razões para sustentá-la. Avalie a relação entre uma razão e a proposta, mesmo quando você discorda dela.',[
  ('Carta fictícia: Defendo mais bancos na praça, porque pessoas que aguardam o barco precisam de lugar para sentar.','Qual é a proposta defendida?','Instalar mais bancos','Trocar o nome do barco','Proibir a espera','A proposta é mais bancos; a necessidade de sentar é o argumento.'),
  ('Comentário fictício: A biblioteca deveria abrir no sábado, pois parte das famílias só pode visitá-la nesse dia.','Qual razão sustenta a proposta?','A disponibilidade dessas famílias','A cor das estantes','O tamanho do título','A disponibilidade está diretamente relacionada à abertura aos sábados.'),
  ('A turma propõe organizar livros por assunto para facilitar a busca.','Qual argumento se relaciona à proposta?','Assuntos semelhantes reunidos ajudam a localizar um tema','Toda proposta da turma é perfeita','A ponte é de madeira','O primeiro argumento explica como a organização facilita a busca.')]),
 (8,'Argumentos e objeções','EF89LP04',178,'8º e 9º anos','Uma objeção pode revelar um limite de uma proposta. Responder bem exige considerar esse limite e apresentar uma razão pertinente, sem atacar a pessoa.',[
  ('Debate fictício: Ivo propõe abrir a biblioteca à noite. Lia lembra que há poucos funcionários disponíveis.','Qual é a objeção de Lia?','A equipe disponível pode não ser suficiente','Livros não têm utilidade','Ivo não gosta de ler','A objeção trata da viabilidade da proposta, não do valor dos livros.'),
  ('Sobre a falta de funcionários, uma colega oferece uma resposta.','Qual resposta enfrenta o problema apresentado?','Avaliar um dia noturno com equipe e escala definidas','Dizer que Lia não entende nada','Ignorar a equipe e mudar de assunto','A resposta apresenta uma alternativa para a limitação mencionada.'),
  ('Duas propostas para o jardim têm custos e benefícios diferentes.','Qual atitude ajuda a avaliar os argumentos?','Comparar razões e dados de cada proposta','Escolher quem fala mais alto','Descartar toda discordância','Comparar razões e dados permite sustentar uma posição e reconhecer limites.')]),
 (9,'Ler a persuasão','EF89LP06',178,'8º e 9º anos','Anúncios e títulos podem persuadir por superlativos, promessas e seleção de fontes. Identifique o recurso e pergunte o que é necessário verificar.',[
  ('Anúncio fictício: O único caderno que garante nota máxima para todos!','Qual recurso persuasivo aparece?','Uma promessa absoluta sem evidência apresentada','Um resultado demonstrado no texto','Uma descrição neutra de tamanho','Único, garante e para todos ampliam a promessa sem demonstrá-la.'),
  ('Uma chamada afirma: Especialistas aprovam o projeto. Não informa nomes nem estudos.','Qual informação faz falta para avaliar a chamada?','Quem são as fontes e em que evidências se apoiam','A cor preferida do leitor','O número de letras do título','A menção genérica a especialistas não permite conferir a fundamentação.'),
  ('Duas chamadas descrevem a mesma proposta: Mudança no jardim e A revolução perfeita que salvará a ilha.','O que a segunda chamada faz?','Usa palavras intensificadoras para valorizar a proposta','Apresenta somente medidas verificadas','Elimina toda interpretação','Revolução, perfeita e salvará intensificam o apelo e orientam a avaliação.')])
]
for grade,title,skill,page,band,intro,rows in texts:
    lesson(grade,'portuguese',title,skill,page,intro,[q(prompt,correct,a,b,why,'Volte ao trecho e procure palavras que sustentem sua escolha.',reading) for reading,prompt,correct,a,b,why in rows],band=band)

science = [
 (1,'Materiais e cuidado','EF01CI01',334,'Objetos podem ser feitos de materiais diferentes. Observe suas características e pense em como reaproveitá-los antes de descartar.',[
  ('Qual objeto costuma ser feito de papel?','Folha de caderno','Colher de aço','Copo de vidro','A folha de caderno é feita de papel. Aço e vidro são outros materiais.'),
  ('Uma caixa de papelão está limpa e firme. Qual ação permite usá-la novamente?','Transformá-la em organizador','Rasgá-la sem necessidade','Misturá-la ao lixo molhado','Usar a caixa como organizador prolonga seu uso.'),
  ('Qual característica ajuda a diferenciar uma colher de metal de um tecido?','A colher é rígida; o tecido pode ser dobrado facilmente','Ambos são sempre líquidos','Todo tecido é transparente','Rigidez e flexibilidade são características que podemos comparar.')]),
 (2,'Objetos e materiais','EF02CI01',336,'Identifique o material de um objeto e relacione a observação ao seu uso. Um mesmo tipo de objeto pode ser produzido com materiais diferentes.',[
  ('A janela da oficina foi feita de vidro transparente. Qual é o material indicado?','Vidro','Papelão','Algodão','O enunciado identifica o vidro como material da janela.'),
  ('Uma mesa é de madeira e outra de metal. O que podemos concluir?','Objetos com uso semelhante podem ter materiais diferentes','Toda mesa precisa ser de madeira','Madeira e metal são o mesmo material','As duas mesas têm uso semelhante, mas os materiais são diferentes.'),
  ('No passado, a família usava um pote de barro; hoje usa um pote de plástico. O que mudou nesse exemplo?','O material do pote','A existência de um recipiente','O fato de o pote ser um objeto','O exemplo compara dois materiais usados para fabricar recipientes.')]),
 (3,'Observar os animais','EF03CI04',338,'Compare alimentação, reprodução e deslocamento de animais conhecidos. Use características observadas, em vez de supor que todos os animais vivem da mesma forma.',[
  ('Um coelho come folhas e capim. Como é sua alimentação nesse exemplo?','Herbívora','Baseada apenas em carne','Feita de pedras','Folhas e capim são partes de plantas; o exemplo descreve alimentação herbívora.'),
  ('Como um peixe de rio geralmente se desloca na água?','Nadando com movimentos do corpo e das nadadeiras','Andando com quatro patas','Usando rodas','Movimentos do corpo e das nadadeiras ajudam o peixe a nadar.'),
  ('Uma borboleta põe ovos em uma planta. O que está sendo observado?','Uma característica da reprodução','A fabricação de um ninho de metal','A migração de todos os peixes','A postura de ovos faz parte da reprodução da borboleta.')]),
 (4,'Cadeias alimentares','EF04CI04',340,'Em uma cadeia alimentar, observe quem produz alimento e quem se alimenta de quem. As setas representam a passagem de matéria e energia do alimento para o consumidor.',[
  ('Na cadeia capim → gafanhoto → sapo, quem é o produtor?','Capim','Gafanhoto','Sapo','O capim produz seu alimento por fotossíntese.'),
  ('Na mesma cadeia, de quem o sapo obtém alimento?','Do gafanhoto','Diretamente do Sol como alimento','De pedras','A seta do gafanhoto para o sapo indica essa relação alimentar.'),
  ('Qual é a fonte primária de energia para o capim nessa cadeia?','Luz do Sol','Som do sapo','Movimento das pedras','A energia solar participa da produção de alimento pelo capim.')]),
 (5,'A água em movimento','EF05CI02',342,'No ciclo da água, mudanças de estado e deslocamentos se conectam. Evaporação, condensação e precipitação ajudam a explicar a circulação da água no ambiente.',[
  ('Uma poça diminui em um dia quente, sem escorrer. Qual processo ajuda a explicar?','Evaporação','Congelamento','Transformação da água em areia','Na evaporação, parte da água líquida passa ao estado gasoso.'),
  ('O vapor de água esfria e forma pequenas gotas. Que mudança ocorre?','Condensação','Fusão','Desaparecimento da matéria','Condensação é a passagem do estado gasoso para o líquido.'),
  ('Qual acontecimento devolve água das nuvens à superfície na forma de chuva?','Precipitação','Aumento do tamanho das pedras','Produção de sal','A precipitação faz parte da circulação da água entre atmosfera e superfície.')]),
 (6,'Comparar misturas','EF06CI01',346,'Observe o aspecto de uma mistura nas condições descritas. Uma fase visível caracteriza a mistura homogênea; duas ou mais fases caracterizam uma mistura heterogênea.',[
  ('Água com uma pequena quantidade de sal totalmente dissolvido apresenta uma fase. Como classificar?','Mistura homogênea','Mistura heterogênea com duas fases','Substância pura por ter aparência uniforme','É uma mistura homogênea: aparência uniforme não significa substância pura.'),
  ('Água e óleo se separam em duas camadas visíveis. Como classificar?','Mistura heterogênea','Mistura homogênea','Material sem componentes','As duas camadas correspondem a fases diferentes.'),
  ('Areia e água permanecem distinguíveis no copo. O que sustenta a classificação como heterogênea?','A presença de fases distinguíveis','O simples fato de haver água','A cor do copo','O critério usado é a presença de fases distinguíveis nas condições observadas.')]),
 (7,'Efeito estufa e ambiente','EF07CI13',348,'O efeito estufa é um processo natural importante para a temperatura da Terra. Seu aumento por mudanças na composição da atmosfera pode intensificar o aquecimento.',[
  ('Qual descrição diferencia o efeito estufa natural de sua intensificação?','O processo é natural, mas atividades humanas podem ampliá-lo','Todo efeito estufa foi criado por máquinas','Eliminar toda a atmosfera manteria o mesmo clima','O processo natural e seu aumento por atividades humanas não são a mesma coisa.'),
  ('Que atividade pode aumentar a emissão de dióxido de carbono?','Queimar combustíveis fósseis','Usar a luz do dia para ler','Caminhar até um lugar próximo','A queima de combustíveis fósseis libera dióxido de carbono.'),
  ('Qual proposta se relaciona ao controle da intensificação do efeito estufa?','Reduzir emissões e conservar a vegetação','Aumentar queimadas','Queimar mais combustível para criar nuvens','Reduzir emissões e conservar a vegetação atua sobre causas relacionadas ao problema.')]),
 (8,'Transformações de energia','EF08CI03',350,'Equipamentos transformam energia. Identifique a transformação principal desejada em cada uso, lembrando que um equipamento pode produzir mais de um efeito.',[
  ('Qual é a transformação principal desejada em um ventilador elétrico?','Elétrica em movimento','Som em alimento','Luz em combustível','O motor usa energia elétrica para movimentar as pás.'),
  ('Em um ferro de passar, qual efeito é principalmente desejado?','Aquecimento a partir de energia elétrica','Produção de gelo','Transformação do tecido em eletricidade','O ferro transforma energia elétrica em energia térmica para aquecer.'),
  ('Uma lâmpada acesa ilumina e também aquece. O que isso mostra?','Pode haver mais de uma transformação de energia','Toda energia vira apenas luz','A energia elétrica deixa de existir sem transformação','Uma parte da energia aparece como luz e outra como aquecimento.')]),
 (9,'Mudanças e partículas','EF09CI01',352,'Modelos de partículas ajudam a explicar estados físicos. A água continua sendo água ao derreter ou evaporar; mudam a organização, o movimento e as distâncias entre suas moléculas.',[
  ('O gelo derrete e vira água líquida. Nesse processo físico, as moléculas de água…','Continuam sendo moléculas de água','Viram moléculas de ferro','Deixam de existir','Na fusão muda a organização das moléculas, não a identidade da substância.'),
  ('Comparando vapor e água líquida, qual descrição é compatível com o modelo de partículas?','No vapor, as moléculas ficam, em média, mais afastadas','No vapor não existem moléculas','No líquido todas as moléculas ficam imóveis','O estado gasoso apresenta, em média, maior separação entre as moléculas.'),
  ('Ao receber energia e aquecer antes de mudar de estado, o que tende a ocorrer com o movimento das partículas?','Fica mais intenso','Cessa completamente','Transforma todas as partículas em luz','O aquecimento está associado ao aumento da agitação das partículas, antes da mudança de estado.')])
]
for grade,title,skill,page,intro,rows in science:
    lesson(grade,'science',title,skill,page,intro,[q(prompt,correct,a,b,why,'Compare o fenômeno com a explicação da trilha.') for prompt,correct,a,b,why in rows])

# Fourth authored distractor for grades 4–9; shared by practice and arcade.
fourth = {
 'math_4': ['7', '6', '25'],
 'math_5': ['80', '30', '100'],
 'math_6': ['4,15 m', '6,40', '10,50'],
 'math_7': ['3', '14', '6'],
 'math_8': ['8', '11', '12'],
 'math_9': ['8', 'f(x) = 2x + 2', 'Sim: basta que as entradas sejam números inteiros'],
 'math_5_fracoes': ['3/5', '5/8', 'Não se pode comparar frações com denominadores diferentes'],
 'math_8_dados': ['3', '4', '15'],
 'portuguese_4': ['Cora estava secando uma toalha ao sol', 'Já tinha terminado a leitura do livro', 'Desatenção com o que havia no caminho'],
 'portuguese_5': ['Gelada', 'Certeza', 'Começou uma viagem diferente'],
 'portuguese_6': ['Esse horário é ótimo para toda a turma', 'A ponte é mais agradável à tarde', 'Concluir que é falso sem consultar os dados'],
 'portuguese_7': ['Reduzir a quantidade de bancos', 'O gosto do autor por desenhos', 'Organizar os livros pelo tamanho da capa resolve qualquer busca'],
 'portuguese_8': ['O prédio precisa ser pintado', 'Repetir a proposta sem explicar como atender à equipe', 'Aceitar qualquer dado sem verificar sua origem'],
 'portuguese_9': ['Uma comparação acompanhada de fontes verificáveis', 'O horário em que o leitor costuma acordar', 'Apresenta dados que provam ser a única solução'],
 'science_4': ['O sapo e o gafanhoto, juntos', 'Do capim, sem consumir outros seres vivos', 'Calor produzido pelo solo'],
 'science_5': ['Condensação do líquido em vapor', 'Solidificação de todo o vapor em gelo', 'Evaporação das gotas antes de alcançarem o solo'],
 'science_6': ['Mistura com uma fase para cada grão de sal dissolvido', 'Substância pura porque os líquidos ficam no mesmo copo', 'A igualdade de tamanho dos grãos e das moléculas'],
 'science_7': ['A intensificação elimina a retenção de calor na atmosfera', 'Utilizar uma bicicleta sem motor', 'Retirar a vegetação para evitar a absorção de luz solar'],
 'science_8': ['Movimento das pás em energia elétrica para alimentar a tomada', 'Conversão da energia elétrica apenas em luz', 'O aquecimento prova que não houve transformação de energia'],
 'science_9': ['São substituídas por moléculas de oxigênio', 'As moléculas do vapor têm sempre tamanho maior que as do líquido', 'As partículas passam a se mover menos, mesmo com a temperatura subindo'],
}
for entry in lessons:
    if entry['grade'] < 4:
        continue
    for item, distractor in zip(entry['questions'], fourth[entry['id']]):
        assert distractor not in item['answers']
        item['answers'].append(distractor)

output=ROOT/'resources/education/bncc_lessons.gd'
output.parent.mkdir(parents=True,exist_ok=True)
output.write_text('extends RefCounted\n## Questões autorais de demonstração; referências indicam recortes da BNCC.\nconst LESSONS := '+json.dumps(lessons,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
