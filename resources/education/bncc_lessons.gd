extends RefCounted
## Questões autorais de demonstração; referências indicam recortes da BNCC.
const LESSONS := [
  {
    "id": "math_1",
    "grade": 1,
    "subject": "math",
    "title": "Juntar e retirar",
    "skill": "EF01MA08",
    "source_page": 281,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "1º ano",
    "intro": "Conte com tampinhas, riscos ou dedos. Juntar aumenta uma coleção; retirar diminui. Por exemplo, 2 pedras e mais 1 pedra formam 3 pedras.",
    "questions": [
      {
        "prompt": "Cora tem 5 sementes e ganha 3. Quantas tem agora?",
        "answers": [
          "8",
          "2",
          "9"
        ],
        "correct": 0,
        "why": "Juntamos 5 + 3: 6, 7, 8 sementes.",
        "hint": "Desenhe cinco bolinhas e acrescente três.",
        "reading": ""
      },
      {
        "prompt": "Havia 9 folhas. O vento levou 4. Quantas ficaram?",
        "answers": [
          "5",
          "13",
          "4"
        ],
        "correct": 0,
        "why": "Retirar quatro de nove deixa cinco: 9 − 4 = 5.",
        "hint": "Risque quatro de nove marcas.",
        "reading": ""
      },
      {
        "prompt": "No banco há 6 ursos. Chegam 2. Quantos ficam?",
        "answers": [
          "8",
          "4",
          "7"
        ],
        "correct": 0,
        "why": "Chegaram mais dois: 6 + 2 = 8.",
        "hint": "Continue a contagem a partir de seis.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_2",
    "grade": 2,
    "subject": "math",
    "title": "Contas em situações",
    "skill": "EF02MA06",
    "source_page": 285,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "2º ano",
    "intro": "Separe centenas, dezenas e unidades. Você pode somar por partes: 120 + 30 = 150. Na subtração, confira somando o que restou ao que foi retirado.",
    "questions": [
      {
        "prompt": "A biblioteca tinha 125 livros e recebeu 40. Quantos tem?",
        "answers": [
          "165",
          "85",
          "129"
        ],
        "correct": 0,
        "why": "125 + 40 = 165. Foram acrescentadas quatro dezenas.",
        "hint": "Some primeiro as dezenas.",
        "reading": ""
      },
      {
        "prompt": "O viveiro tinha 230 mudas e doou 110. Quantas restaram?",
        "answers": [
          "120",
          "340",
          "220"
        ],
        "correct": 0,
        "why": "230 − 110 = 120. Confira: 120 + 110 = 230.",
        "hint": "Separe centenas e dezenas.",
        "reading": ""
      },
      {
        "prompt": "Uma turma recolheu 48 papéis de manhã e 27 à tarde. Qual é o total?",
        "answers": [
          "75",
          "65",
          "21"
        ],
        "correct": 0,
        "why": "48 + 20 = 68; 68 + 7 = 75.",
        "hint": "Some vinte e depois sete.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_3",
    "grade": 3,
    "subject": "math",
    "title": "Grupos iguais",
    "skill": "EF03MA07",
    "source_page": 289,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "3º ano",
    "intro": "Multiplicar pode organizar grupos com a mesma quantidade. Três caixas com 2 lápis cada representam 2 + 2 + 2 = 6. Desenhe os grupos antes de calcular.",
    "questions": [
      {
        "prompt": "Quatro vasos têm 3 flores cada. Quantas flores?",
        "answers": [
          "12",
          "7",
          "9"
        ],
        "correct": 0,
        "why": "São quatro grupos de três: 3 + 3 + 3 + 3 = 12.",
        "hint": "Conte quatro grupos de três.",
        "reading": ""
      },
      {
        "prompt": "Cinco bancos têm 2 lugares cada. Quantos lugares?",
        "answers": [
          "10",
          "7",
          "12"
        ],
        "correct": 0,
        "why": "Cinco grupos de dois formam dez: 5 × 2 = 10.",
        "hint": "Conte de dois em dois cinco vezes.",
        "reading": ""
      },
      {
        "prompt": "Há 3 filas com 10 sementes em cada fila. Qual é o total?",
        "answers": [
          "30",
          "13",
          "20"
        ],
        "correct": 0,
        "why": "As três filas têm a mesma quantidade: 10 + 10 + 10 = 30.",
        "hint": "Cada fila acrescenta uma dezena.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_4",
    "grade": 4,
    "subject": "math",
    "title": "Repartir e agrupar",
    "skill": "EF04MA07",
    "source_page": 293,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "4º ano",
    "intro": "Dividir pode repartir igualmente ou descobrir quantos grupos cabem. Se 18 sementes vão para 3 vasos igualmente, cada vaso recebe 6. Confira multiplicando.",
    "questions": [
      {
        "prompt": "48 sementes são repartidas igualmente em 6 vasos. Quantas por vaso?",
        "answers": [
          "8",
          "6",
          "9"
        ],
        "correct": 0,
        "why": "48 ÷ 6 = 8, pois 6 × 8 = 48.",
        "hint": "Procure um número que, multiplicado por seis, resulte em 48.",
        "reading": ""
      },
      {
        "prompt": "96 livros serão colocados em caixas de 12. Quantas caixas completas?",
        "answers": [
          "8",
          "12",
          "9"
        ],
        "correct": 0,
        "why": "96 ÷ 12 = 8 caixas. Aqui procuramos quantos grupos de doze cabem.",
        "hint": "Some doze repetidamente ou use a multiplicação.",
        "reading": ""
      },
      {
        "prompt": "75 adesivos são repartidos igualmente entre 5 ursos. Quantos para cada?",
        "answers": [
          "15",
          "10",
          "20"
        ],
        "correct": 0,
        "why": "75 ÷ 5 = 15: cinco grupos de quinze totalizam 75.",
        "hint": "Separe 75 em 50 + 25 e divida cada parte por cinco.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_5",
    "grade": 5,
    "subject": "math",
    "title": "Porcentagens do cotidiano",
    "skill": "EF05MA06",
    "source_page": 297,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "5º ano",
    "intro": "Porcentagem compara uma quantidade com cem partes. 50% é metade; 25% é um quarto; 10% é um décimo. De 60 sementes, por exemplo, 50% são 30.",
    "questions": [
      {
        "prompt": "Qual é 50% de 80 sementes?",
        "answers": [
          "40",
          "50",
          "160"
        ],
        "correct": 0,
        "why": "50% significa metade: 80 ÷ 2 = 40.",
        "hint": "Encontre a metade de oitenta.",
        "reading": ""
      },
      {
        "prompt": "Qual é 25% de 40 páginas?",
        "answers": [
          "10",
          "25",
          "20"
        ],
        "correct": 0,
        "why": "25% é um quarto. Divida quarenta em quatro partes iguais: 10.",
        "hint": "Um quarto corresponde a uma de quatro partes iguais.",
        "reading": ""
      },
      {
        "prompt": "Um item de 100 moedas tem desconto de 10%. Qual é o preço final?",
        "answers": [
          "90",
          "10",
          "110"
        ],
        "correct": 0,
        "why": "10% de 100 são 10. O desconto reduz o preço: 100 − 10 = 90.",
        "hint": "Primeiro calcule o desconto; depois retire-o do preço.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_6",
    "grade": 6,
    "subject": "math",
    "title": "Operações com decimais",
    "skill": "EF06MA11",
    "source_page": 303,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "6º ano",
    "intro": "Nas somas e subtrações, alinhe as casas decimais. Estime antes: 3,20 + 1,90 deve ficar perto de 5. Em situações de preço, explique o resultado com sua unidade.",
    "questions": [
      {
        "prompt": "Uma fita mede 2,5 m e outra 1,75 m. Qual é a soma?",
        "answers": [
          "4,25 m",
          "3,25 m",
          "4,75 m"
        ],
        "correct": 0,
        "why": "Escreva 2,50 + 1,75 = 4,25 metros.",
        "hint": "Complete 2,5 com um zero: 2,50.",
        "reading": ""
      },
      {
        "prompt": "Uma compra custa 12,60 moedas. O pagamento foi 20,00. Qual é o troco?",
        "answers": [
          "7,40",
          "8,60",
          "32,60"
        ],
        "correct": 0,
        "why": "20,00 − 12,60 = 7,40. A compra mais o troco recompõe vinte.",
        "hint": "Faça a diferença entre pagamento e preço.",
        "reading": ""
      },
      {
        "prompt": "Quatro cadernos custam 3,50 moedas cada. Qual é o total?",
        "answers": [
          "14,00",
          "7,50",
          "12,00"
        ],
        "correct": 0,
        "why": "3,50 × 4 = 14,00. São quatro parcelas de 3,50.",
        "hint": "Calcule quatro vezes três e quatro vezes meio.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_7",
    "grade": 7,
    "subject": "math",
    "title": "Encontrar a incógnita",
    "skill": "EF07MA18",
    "source_page": 309,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "7º ano",
    "intro": "Uma equação mantém os dois lados iguais. Para resolver 2x + 3 = 11, retire 3 dos dois lados e depois divida ambos por 2. Assim, x = 4. Confira substituindo.",
    "questions": [
      {
        "prompt": "Qual valor de x resolve 3x + 5 = 20?",
        "answers": [
          "5",
          "15",
          "8"
        ],
        "correct": 0,
        "why": "Retire 5: 3x = 15. Divida por 3: x = 5. Confira 3 × 5 + 5 = 20.",
        "hint": "Desfaça primeiro a adição, depois a multiplicação.",
        "reading": ""
      },
      {
        "prompt": "Qual valor de x resolve 2x − 4 = 10?",
        "answers": [
          "7",
          "3",
          "5"
        ],
        "correct": 0,
        "why": "Some 4 aos dois lados: 2x = 14. Divida por 2: x = 7.",
        "hint": "A operação inversa de retirar quatro é acrescentar quatro.",
        "reading": ""
      },
      {
        "prompt": "Três ingressos iguais e uma taxa de 6 moedas custam 30. Qual é o preço de cada ingresso?",
        "answers": [
          "8",
          "12",
          "10"
        ],
        "correct": 0,
        "why": "3x + 6 = 30; 3x = 24; x = 8 moedas.",
        "hint": "Separe a taxa antes de dividir entre os ingressos.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_8",
    "grade": 8,
    "subject": "math",
    "title": "Expressões e substituição",
    "skill": "EF08MA06",
    "source_page": 315,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "8º ano",
    "intro": "Para calcular uma expressão, substitua a letra pelo valor indicado. Respeite parênteses e potências antes das demais operações. Se x = 3, então x² + 1 = 10.",
    "questions": [
      {
        "prompt": "Se x = 4, quanto vale 2x + 3?",
        "answers": [
          "11",
          "14",
          "9"
        ],
        "correct": 0,
        "why": "Substitua x por 4: 2 × 4 + 3 = 11.",
        "hint": "A multiplicação vem antes da adição.",
        "reading": ""
      },
      {
        "prompt": "Se a = 3 e b = 2, quanto vale a² − b?",
        "answers": [
          "7",
          "1",
          "5"
        ],
        "correct": 0,
        "why": "3² − 2 = 9 − 2 = 7. Elevar ao quadrado não é multiplicar por dois.",
        "hint": "Calcule primeiro três ao quadrado.",
        "reading": ""
      },
      {
        "prompt": "Se x = 5, quanto vale 2(x − 1)?",
        "answers": [
          "8",
          "9",
          "4"
        ],
        "correct": 0,
        "why": "Primeiro 5 − 1 = 4; depois 2 × 4 = 8.",
        "hint": "Resolva o que está entre parênteses.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_9",
    "grade": 9,
    "subject": "math",
    "title": "Relações e funções",
    "skill": "EF09MA06",
    "source_page": 319,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "9º ano",
    "intro": "Uma função associa cada entrada a uma única saída. Em C(n) = 4n + 2, n pode indicar itens e C o custo: há uma parte variável e uma taxa fixa. Use uma tabela para observar a relação.",
    "questions": [
      {
        "prompt": "Em C(n) = 3n + 5, qual é C(4)?",
        "answers": [
          "17",
          "12",
          "20"
        ],
        "correct": 0,
        "why": "Substitua n por 4: 3 × 4 + 5 = 17.",
        "hint": "A entrada quatro ocupa o lugar de n.",
        "reading": ""
      },
      {
        "prompt": "Uma tabela tem entradas 1, 2, 3 e saídas 4, 7, 10. Qual regra serve para todas?",
        "answers": [
          "f(x) = 3x + 1",
          "f(x) = x + 3",
          "f(x) = 4x"
        ],
        "correct": 0,
        "why": "3 × 1 + 1 = 4; 3 × 2 + 1 = 7; 3 × 3 + 1 = 10.",
        "hint": "Não basta acertar uma linha: confira as três.",
        "reading": ""
      },
      {
        "prompt": "No registro de uma máquina, a mesma entrada 2 produz 5 e 7 sem nenhuma outra condição. Esse registro define uma função da entrada para a saída?",
        "answers": [
          "Não: uma entrada tem duas saídas",
          "Sim: toda tabela define função",
          "Sim: as saídas são positivas"
        ],
        "correct": 0,
        "why": "Uma função precisa dar uma única saída para cada entrada. Esse registro viola a condição.",
        "hint": "Observe se a saída fica determinada por uma única entrada.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_3_figuras",
    "grade": 3,
    "subject": "math",
    "title": "Investigar figuras",
    "skill": "EF03MA15",
    "source_page": 291,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "3º ano",
    "intro": "Observe lados e vértices, não apenas a posição da figura. Girar um quadrado não altera seus quatro lados iguais. Um desenho inclinado continua sendo a mesma figura.",
    "questions": [
      {
        "prompt": "Uma figura plana fechada tem três lados retos e três vértices. Qual é?",
        "answers": [
          "Triângulo",
          "Quadrado",
          "Círculo"
        ],
        "correct": 0,
        "why": "Um triângulo tem três lados e três vértices.",
        "hint": "Conte os segmentos retos e seus encontros.",
        "reading": ""
      },
      {
        "prompt": "O que quadrado e retângulo têm em comum?",
        "answers": [
          "Quatro lados e quatro vértices",
          "Sempre quatro lados do mesmo comprimento",
          "Três vértices"
        ],
        "correct": 0,
        "why": "Ambos têm quatro lados e quatro vértices. Um retângulo não precisa ter os quatro lados iguais.",
        "hint": "Compare características, sem depender do tamanho.",
        "reading": ""
      },
      {
        "prompt": "Cora girou um quadrado de papel, sem dobrá-lo nem cortá-lo. O que aconteceu com o número de lados?",
        "answers": [
          "Continuou quatro",
          "Passou a três",
          "Passou a cinco"
        ],
        "correct": 0,
        "why": "A rotação muda a posição, não a quantidade de lados.",
        "hint": "Pense no que mudou e no que permaneceu.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_5_fracoes",
    "grade": 5,
    "subject": "math",
    "title": "Frações equivalentes",
    "skill": "EF05MA04",
    "source_page": 297,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "5º ano",
    "intro": "Frações equivalentes representam a mesma quantidade. Se cada metade é dividida novamente em duas partes, 1/2 passa a ser representada por 2/4. O tamanho do inteiro precisa ser o mesmo.",
    "questions": [
      {
        "prompt": "Qual fração é equivalente a 1/2?",
        "answers": [
          "2/4",
          "1/4",
          "2/3"
        ],
        "correct": 0,
        "why": "Multiplicar numerador e denominador de 1/2 por dois dá 2/4.",
        "hint": "Divida cada uma das duas metades em duas partes.",
        "reading": ""
      },
      {
        "prompt": "Qual fração é equivalente a 3/4?",
        "answers": [
          "6/8",
          "3/8",
          "4/6"
        ],
        "correct": 0,
        "why": "Multiplique os dois termos por dois: 3/4 = 6/8.",
        "hint": "A mesma operação deve atingir numerador e denominador.",
        "reading": ""
      },
      {
        "prompt": "Do mesmo bolo, Lia comeu 2/6 e Ivo comeu 1/3. Quem comeu mais?",
        "answers": [
          "Comeram a mesma quantidade",
          "Lia comeu mais",
          "Ivo comeu mais"
        ],
        "correct": 0,
        "why": "Dividindo os dois termos de 2/6 por dois, obtemos 1/3.",
        "hint": "Compare as frações usando partes do mesmo inteiro.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "math_8_dados",
    "grade": 8,
    "subject": "math",
    "title": "Ler dados e calcular",
    "skill": "EF08MA25",
    "source_page": 317,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "8º ano",
    "intro": "A média soma os valores e divide pela quantidade. A moda é o valor mais frequente. A mediana é o valor central depois de ordenar os dados. Essas medidas respondem a perguntas diferentes.",
    "questions": [
      {
        "prompt": "As quantidades de livros lidos foram 2, 4 e 6. Qual é a média?",
        "answers": [
          "4",
          "6",
          "12"
        ],
        "correct": 0,
        "why": "A soma é 12; há três valores; 12 ÷ 3 = 4.",
        "hint": "Não confunda a soma com a média.",
        "reading": ""
      },
      {
        "prompt": "Nos dados 1, 2, 2 e 5, qual é a moda?",
        "answers": [
          "2",
          "5",
          "1"
        ],
        "correct": 0,
        "why": "O valor dois aparece duas vezes; os demais aparecem uma.",
        "hint": "Procure o valor mais frequente.",
        "reading": ""
      },
      {
        "prompt": "Depois de ordenar os dados 7, 3 e 5, qual é a mediana?",
        "answers": [
          "5",
          "3",
          "7"
        ],
        "correct": 0,
        "why": "A ordem é 3, 5, 7. O elemento central é 5.",
        "hint": "Ordene antes de procurar o centro.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_1",
    "grade": 1,
    "subject": "portuguese",
    "title": "Encontrar no texto",
    "skill": "EF15LP03",
    "source_page": 97,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "1º ao 5º ano",
    "intro": "Leia ou peça a alguém para ler. Volte ao texto para encontrar a informação, em vez de adivinhar.",
    "questions": [
      {
        "prompt": "QUAL É A COR DO LIVRO?",
        "answers": [
          "AZUL",
          "VERDE",
          "AMARELO"
        ],
        "correct": 0,
        "why": "O texto diz que o livro é azul.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "CORA TEM UM LIVRO. O LIVRO É AZUL."
      },
      {
        "prompt": "ONDE IVO VIU O PEIXE?",
        "answers": [
          "NO RIO",
          "NO DOJO",
          "NO BANCO"
        ],
        "correct": 0,
        "why": "A expressão NO RIO conta o lugar.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "IVO VIU UM PEIXE NO RIO."
      },
      {
        "prompt": "O QUE LIA LEVOU?",
        "answers": [
          "UMA MAÇÃ",
          "UM BARCO",
          "UMA BOLA"
        ],
        "correct": 0,
        "why": "O objeto levado aparece na frase: UMA MAÇÃ.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "LIA LEVOU UMA MAÇÃ PARA O PASSEIO."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_2",
    "grade": 2,
    "subject": "portuguese",
    "title": "Ler com atenção",
    "skill": "EF15LP03",
    "source_page": 97,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "1º ao 5º ano",
    "intro": "Identifique quem participa, o que acontece e onde ou quando. Uma palavra da pergunta pode ajudar a procurar a passagem certa.",
    "questions": [
      {
        "prompt": "Em que dia aconteceu a visita?",
        "answers": [
          "Quinta-feira",
          "Terça-feira",
          "Domingo"
        ],
        "correct": 0,
        "why": "O dia aparece no início do texto.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Na quinta-feira, a turma visitou o porto. Cora levou um caderno para desenhar."
      },
      {
        "prompt": "Em qual caixa ficaram as sementes?",
        "answers": [
          "Na verde",
          "Na azul",
          "Em nenhuma"
        ],
        "correct": 0,
        "why": "A primeira frase informa onde Ivo as guardou.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Ivo guardou as sementes na caixa verde. A caixa azul ficou vazia."
      },
      {
        "prompt": "O que Lia devolveu?",
        "answers": [
          "O livro",
          "O almoço",
          "Uma semente"
        ],
        "correct": 0,
        "why": "Devolveu se refere ao livro que ela havia lido.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Lia terminou a leitura e devolveu o livro à biblioteca antes do almoço."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_3",
    "grade": 3,
    "subject": "portuguese",
    "title": "Compreender o essencial",
    "skill": "EF35LP03",
    "source_page": 115,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "3º ao 5º ano",
    "intro": "A ideia central liga as informações do texto. Um detalhe pode ser verdadeiro e, mesmo assim, não resumir a mensagem principal.",
    "questions": [
      {
        "prompt": "Qual é a ideia central?",
        "answers": [
          "Cuidar dos resíduos na praça",
          "Comprar cadernos novos",
          "Escolher o banco mais alto"
        ],
        "correct": 0,
        "why": "As duas ações tratam dos resíduos e de como reduzi-los.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "A turma recolheu papéis e separou materiais reutilizáveis. Depois, combinou formas de produzir menos lixo na praça."
      },
      {
        "prompt": "Qual é a ideia central?",
        "answers": [
          "Planejar ajuda a cumprir horários",
          "Todos os barcos são iguais",
          "Avisos nunca mudam"
        ],
        "correct": 0,
        "why": "Ler avisos e conferir horários são ações de planejamento.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Cora leu os avisos antes da viagem e conferiu os horários. Assim, chegou ao embarque no momento combinado."
      },
      {
        "prompt": "Qual é a ideia central?",
        "answers": [
          "Construir uma decisão em conjunto",
          "Medir a altura de uma árvore",
          "Pintar todas as flores"
        ],
        "correct": 0,
        "why": "Ouvir e escolher juntos formam o núcleo do texto.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Os ursos ouviram sugestões diferentes para o jardim. Juntos, escolheram uma proposta que atendia à turma."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_4",
    "grade": 4,
    "subject": "portuguese",
    "title": "Investigar pistas",
    "skill": "EF35LP04",
    "source_page": 115,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "3º ao 5º ano",
    "intro": "Uma inferência combina pistas do texto com conhecimentos pertinentes. Procure evidências e evite acrescentar detalhes que o texto não sustenta.",
    "questions": [
      {
        "prompt": "O que é mais provável?",
        "answers": [
          "Estava chovendo",
          "Estava nevando dentro do dojo",
          "Cora acabara de nadar"
        ],
        "correct": 0,
        "why": "Guarda-chuva molhado e gotas na janela sustentam a inferência de chuva.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Cora entrou com o guarda-chuva molhado. Lá fora, gotas batiam na janela."
      },
      {
        "prompt": "Por que Ivo provavelmente se sentiu aliviado?",
        "answers": [
          "Queria encontrar o livro",
          "Queria esconder o livro",
          "Não sabia o que era uma prateleira"
        ],
        "correct": 0,
        "why": "A busca e o sorriso ligam o alívio ao encontro do livro.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Ivo procurou o livro em todas as prateleiras. Quando Lia o encontrou, ele sorriu aliviado."
      },
      {
        "prompt": "Que atitude essas ações sugerem?",
        "answers": [
          "Cuidado ao atravessar",
          "Pressa para correr",
          "Vontade de pular na água"
        ],
        "correct": 0,
        "why": "Passo mais lento e uso do corrimão indicam cuidado.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Antes de atravessar a ponte estreita, Lia diminuiu o passo e segurou o corrimão."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_5",
    "grade": 5,
    "subject": "portuguese",
    "title": "Palavras em contexto",
    "skill": "EF35LP05",
    "source_page": 115,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "3º ao 5º ano",
    "intro": "Leia o entorno de uma palavra desconhecida. A situação e as demais expressões ajudam a construir um sentido possível.",
    "questions": [
      {
        "prompt": "Nesse contexto, escassa significa…",
        "answers": [
          "Pouca",
          "Abundante",
          "Colorida"
        ],
        "correct": 0,
        "why": "Restava muito pouco explica o sentido de escassa.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "A água ficou escassa durante a seca: restava muito pouco no reservatório."
      },
      {
        "prompt": "Cautela indica…",
        "answers": [
          "Cuidado",
          "Distração",
          "Barulho"
        ],
        "correct": 0,
        "why": "Observar as tábuas antes de avançar é agir com cuidado.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Lia avançou com cautela, observando cada tábua solta da ponte."
      },
      {
        "prompt": "Retomou significa…",
        "answers": [
          "Continuou novamente",
          "Cancelou para sempre",
          "Esqueceu o caminho"
        ],
        "correct": 0,
        "why": "O passeio havia parado; retomar é dar continuidade a ele.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "A chuva parou e a turma retomou o passeio, que havia sido interrompido."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_6",
    "grade": 6,
    "subject": "portuguese",
    "title": "Fato e opinião",
    "skill": "EF67LP04",
    "source_page": 165,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "6º e 7º anos",
    "intro": "Diferencie afirmações verificáveis de avaliações pessoais. Uma afirmação verificável ainda precisa de conferência; parecer um fato não a torna automaticamente verdadeira.",
    "questions": [
      {
        "prompt": "Qual trecho expressa uma opinião?",
        "answers": [
          "Esse é o melhor horário",
          "A biblioteca abre às 8h",
          "O aviso está escrito"
        ],
        "correct": 0,
        "why": "Melhor é uma avaliação pessoal; o horário pode ser conferido.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "O aviso afirma: A biblioteca abre às 8h. Cora comenta: Esse é o melhor horário."
      },
      {
        "prompt": "Qual informação pode ser conferida por medição?",
        "answers": [
          "A ponte mede 12 metros",
          "É a mais bonita",
          "Ivo gosta da ponte"
        ],
        "correct": 0,
        "why": "O comprimento pode ser medido. A beleza envolve julgamento.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Ivo escreveu: A ponte mede 12 metros e é a mais bonita da ilha."
      },
      {
        "prompt": "Qual é o próximo passo para verificar essa afirmação?",
        "answers": [
          "Consultar o registro dos empréstimos",
          "Acreditar porque há um número",
          "Decidir pela cor da postagem"
        ],
        "correct": 0,
        "why": "Um número não comprova a afirmação: é preciso conferir a fonte.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Uma postagem diz: Ontem foram emprestados 20 livros."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_7",
    "grade": 7,
    "subject": "portuguese",
    "title": "Posições e razões",
    "skill": "EF67LP05",
    "source_page": 165,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "6º e 7º anos",
    "intro": "Uma tese expressa a posição defendida. Os argumentos apresentam razões para sustentá-la. Avalie a relação entre uma razão e a proposta, mesmo quando você discorda dela.",
    "questions": [
      {
        "prompt": "Qual é a proposta defendida?",
        "answers": [
          "Instalar mais bancos",
          "Trocar o nome do barco",
          "Proibir a espera"
        ],
        "correct": 0,
        "why": "A proposta é mais bancos; a necessidade de sentar é o argumento.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Carta fictícia: Defendo mais bancos na praça, porque pessoas que aguardam o barco precisam de lugar para sentar."
      },
      {
        "prompt": "Qual razão sustenta a proposta?",
        "answers": [
          "A disponibilidade dessas famílias",
          "A cor das estantes",
          "O tamanho do título"
        ],
        "correct": 0,
        "why": "A disponibilidade está diretamente relacionada à abertura aos sábados.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Comentário fictício: A biblioteca deveria abrir no sábado, pois parte das famílias só pode visitá-la nesse dia."
      },
      {
        "prompt": "Qual argumento se relaciona à proposta?",
        "answers": [
          "Assuntos semelhantes reunidos ajudam a localizar um tema",
          "Toda proposta da turma é perfeita",
          "A ponte é de madeira"
        ],
        "correct": 0,
        "why": "O primeiro argumento explica como a organização facilita a busca.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "A turma propõe organizar livros por assunto para facilitar a busca."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_8",
    "grade": 8,
    "subject": "portuguese",
    "title": "Argumentos e objeções",
    "skill": "EF89LP04",
    "source_page": 179,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "8º e 9º anos",
    "intro": "Uma objeção pode revelar um limite de uma proposta. Responder bem exige considerar esse limite e apresentar uma razão pertinente, sem atacar a pessoa.",
    "questions": [
      {
        "prompt": "Qual é a objeção de Lia?",
        "answers": [
          "A equipe disponível pode não ser suficiente",
          "Livros não têm utilidade",
          "Ivo não gosta de ler"
        ],
        "correct": 0,
        "why": "A objeção trata da viabilidade da proposta, não do valor dos livros.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Debate fictício: Ivo propõe abrir a biblioteca à noite. Lia lembra que há poucos funcionários disponíveis."
      },
      {
        "prompt": "Qual resposta enfrenta o problema apresentado?",
        "answers": [
          "Avaliar um dia noturno com equipe e escala definidas",
          "Dizer que Lia não entende nada",
          "Ignorar a equipe e mudar de assunto"
        ],
        "correct": 0,
        "why": "A resposta apresenta uma alternativa para a limitação mencionada.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Sobre a falta de funcionários, uma colega oferece uma resposta."
      },
      {
        "prompt": "Qual atitude ajuda a avaliar os argumentos?",
        "answers": [
          "Comparar razões e dados de cada proposta",
          "Escolher quem fala mais alto",
          "Descartar toda discordância"
        ],
        "correct": 0,
        "why": "Comparar razões e dados permite sustentar uma posição e reconhecer limites.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Duas propostas para o jardim têm custos e benefícios diferentes."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "portuguese_9",
    "grade": 9,
    "subject": "portuguese",
    "title": "Ler a persuasão",
    "skill": "EF89LP06",
    "source_page": 179,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "8º e 9º anos",
    "intro": "Anúncios e títulos podem persuadir por superlativos, promessas e seleção de fontes. Identifique o recurso e pergunte o que é necessário verificar.",
    "questions": [
      {
        "prompt": "Qual recurso persuasivo aparece?",
        "answers": [
          "Uma promessa absoluta sem evidência apresentada",
          "Um resultado demonstrado no texto",
          "Uma descrição neutra de tamanho"
        ],
        "correct": 0,
        "why": "Único, garante e para todos ampliam a promessa sem demonstrá-la.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Anúncio fictício: O único caderno que garante nota máxima para todos!"
      },
      {
        "prompt": "Qual informação faz falta para avaliar a chamada?",
        "answers": [
          "Quem são as fontes e em que evidências se apoiam",
          "A cor preferida do leitor",
          "O número de letras do título"
        ],
        "correct": 0,
        "why": "A menção genérica a especialistas não permite conferir a fundamentação.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Uma chamada afirma: Especialistas aprovam o projeto. Não informa nomes nem estudos."
      },
      {
        "prompt": "O que a segunda chamada faz?",
        "answers": [
          "Usa palavras intensificadoras para valorizar a proposta",
          "Apresenta somente medidas verificadas",
          "Elimina toda interpretação"
        ],
        "correct": 0,
        "why": "Revolução, perfeita e salvará intensificam o apelo e orientam a avaliação.",
        "hint": "Volte ao trecho e procure palavras que sustentem sua escolha.",
        "reading": "Duas chamadas descrevem a mesma proposta: Mudança no jardim e A revolução perfeita que salvará a ilha."
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_1",
    "grade": 1,
    "subject": "science",
    "title": "Materiais e cuidado",
    "skill": "EF01CI01",
    "source_page": 335,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "1º ano",
    "intro": "Objetos podem ser feitos de materiais diferentes. Observe suas características e pense em como reaproveitá-los antes de descartar.",
    "questions": [
      {
        "prompt": "Qual objeto costuma ser feito de papel?",
        "answers": [
          "Folha de caderno",
          "Colher de aço",
          "Copo de vidro"
        ],
        "correct": 0,
        "why": "A folha de caderno é feita de papel. Aço e vidro são outros materiais.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Uma caixa de papelão está limpa e firme. Qual ação permite usá-la novamente?",
        "answers": [
          "Transformá-la em organizador",
          "Rasgá-la sem necessidade",
          "Misturá-la ao lixo molhado"
        ],
        "correct": 0,
        "why": "Usar a caixa como organizador prolonga seu uso.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Qual característica ajuda a diferenciar uma colher de metal de um tecido?",
        "answers": [
          "A colher é rígida; o tecido pode ser dobrado facilmente",
          "Ambos são sempre líquidos",
          "Todo tecido é transparente"
        ],
        "correct": 0,
        "why": "Rigidez e flexibilidade são características que podemos comparar.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_2",
    "grade": 2,
    "subject": "science",
    "title": "Objetos e materiais",
    "skill": "EF02CI01",
    "source_page": 337,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "2º ano",
    "intro": "Identifique o material de um objeto e relacione a observação ao seu uso. Um mesmo tipo de objeto pode ser produzido com materiais diferentes.",
    "questions": [
      {
        "prompt": "A janela da oficina foi feita de vidro transparente. Qual é o material indicado?",
        "answers": [
          "Vidro",
          "Papelão",
          "Algodão"
        ],
        "correct": 0,
        "why": "O enunciado identifica o vidro como material da janela.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Uma mesa é de madeira e outra de metal. O que podemos concluir?",
        "answers": [
          "Objetos com uso semelhante podem ter materiais diferentes",
          "Toda mesa precisa ser de madeira",
          "Madeira e metal são o mesmo material"
        ],
        "correct": 0,
        "why": "As duas mesas têm uso semelhante, mas os materiais são diferentes.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "No passado, a família usava um pote de barro; hoje usa um pote de plástico. O que mudou nesse exemplo?",
        "answers": [
          "O material do pote",
          "A existência de um recipiente",
          "O fato de o pote ser um objeto"
        ],
        "correct": 0,
        "why": "O exemplo compara dois materiais usados para fabricar recipientes.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_3",
    "grade": 3,
    "subject": "science",
    "title": "Observar os animais",
    "skill": "EF03CI04",
    "source_page": 339,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "3º ano",
    "intro": "Compare alimentação, reprodução e deslocamento de animais conhecidos. Use características observadas, em vez de supor que todos os animais vivem da mesma forma.",
    "questions": [
      {
        "prompt": "Um coelho come folhas e capim. Como é sua alimentação nesse exemplo?",
        "answers": [
          "Herbívora",
          "Baseada apenas em carne",
          "Feita de pedras"
        ],
        "correct": 0,
        "why": "Folhas e capim são partes de plantas; o exemplo descreve alimentação herbívora.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Como um peixe de rio geralmente se desloca na água?",
        "answers": [
          "Nadando com movimentos do corpo e das nadadeiras",
          "Andando com quatro patas",
          "Usando rodas"
        ],
        "correct": 0,
        "why": "Movimentos do corpo e das nadadeiras ajudam o peixe a nadar.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Uma borboleta põe ovos em uma planta. O que está sendo observado?",
        "answers": [
          "Uma característica da reprodução",
          "A fabricação de um ninho de metal",
          "A migração de todos os peixes"
        ],
        "correct": 0,
        "why": "A postura de ovos faz parte da reprodução da borboleta.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_4",
    "grade": 4,
    "subject": "science",
    "title": "Cadeias alimentares",
    "skill": "EF04CI04",
    "source_page": 341,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "4º ano",
    "intro": "Em uma cadeia alimentar, observe quem produz alimento e quem se alimenta de quem. As setas representam a passagem de matéria e energia do alimento para o consumidor.",
    "questions": [
      {
        "prompt": "Na cadeia capim → gafanhoto → sapo, quem é o produtor?",
        "answers": [
          "Capim",
          "Gafanhoto",
          "Sapo"
        ],
        "correct": 0,
        "why": "O capim produz seu alimento por fotossíntese.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Na mesma cadeia, de quem o sapo obtém alimento?",
        "answers": [
          "Do gafanhoto",
          "Diretamente do Sol como alimento",
          "De pedras"
        ],
        "correct": 0,
        "why": "A seta do gafanhoto para o sapo indica essa relação alimentar.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Qual é a fonte primária de energia para o capim nessa cadeia?",
        "answers": [
          "Luz do Sol",
          "Som do sapo",
          "Movimento das pedras"
        ],
        "correct": 0,
        "why": "A energia solar participa da produção de alimento pelo capim.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_5",
    "grade": 5,
    "subject": "science",
    "title": "A água em movimento",
    "skill": "EF05CI02",
    "source_page": 343,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "5º ano",
    "intro": "No ciclo da água, mudanças de estado e deslocamentos se conectam. Evaporação, condensação e precipitação ajudam a explicar a circulação da água no ambiente.",
    "questions": [
      {
        "prompt": "Uma poça diminui em um dia quente, sem escorrer. Qual processo ajuda a explicar?",
        "answers": [
          "Evaporação",
          "Congelamento",
          "Transformação da água em areia"
        ],
        "correct": 0,
        "why": "Na evaporação, parte da água líquida passa ao estado gasoso.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "O vapor de água esfria e forma pequenas gotas. Que mudança ocorre?",
        "answers": [
          "Condensação",
          "Fusão",
          "Desaparecimento da matéria"
        ],
        "correct": 0,
        "why": "Condensação é a passagem do estado gasoso para o líquido.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Qual acontecimento devolve água das nuvens à superfície na forma de chuva?",
        "answers": [
          "Precipitação",
          "Aumento do tamanho das pedras",
          "Produção de sal"
        ],
        "correct": 0,
        "why": "A precipitação faz parte da circulação da água entre atmosfera e superfície.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_6",
    "grade": 6,
    "subject": "science",
    "title": "Comparar misturas",
    "skill": "EF06CI01",
    "source_page": 347,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "6º ano",
    "intro": "Observe o aspecto de uma mistura nas condições descritas. Uma fase visível caracteriza a mistura homogênea; duas ou mais fases caracterizam uma mistura heterogênea.",
    "questions": [
      {
        "prompt": "Água com uma pequena quantidade de sal totalmente dissolvido apresenta uma fase. Como classificar?",
        "answers": [
          "Mistura homogênea",
          "Mistura heterogênea com duas fases",
          "Substância pura por ter aparência uniforme"
        ],
        "correct": 0,
        "why": "É uma mistura homogênea: aparência uniforme não significa substância pura.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Água e óleo se separam em duas camadas visíveis. Como classificar?",
        "answers": [
          "Mistura heterogênea",
          "Mistura homogênea",
          "Material sem componentes"
        ],
        "correct": 0,
        "why": "As duas camadas correspondem a fases diferentes.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Areia e água permanecem distinguíveis no copo. O que sustenta a classificação como heterogênea?",
        "answers": [
          "A presença de fases distinguíveis",
          "O simples fato de haver água",
          "A cor do copo"
        ],
        "correct": 0,
        "why": "O critério usado é a presença de fases distinguíveis nas condições observadas.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_7",
    "grade": 7,
    "subject": "science",
    "title": "Efeito estufa e ambiente",
    "skill": "EF07CI13",
    "source_page": 349,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "7º ano",
    "intro": "O efeito estufa é um processo natural importante para a temperatura da Terra. Seu aumento por mudanças na composição da atmosfera pode intensificar o aquecimento.",
    "questions": [
      {
        "prompt": "Qual descrição diferencia o efeito estufa natural de sua intensificação?",
        "answers": [
          "O processo é natural, mas atividades humanas podem ampliá-lo",
          "Todo efeito estufa foi criado por máquinas",
          "Eliminar toda a atmosfera manteria o mesmo clima"
        ],
        "correct": 0,
        "why": "O processo natural e seu aumento por atividades humanas não são a mesma coisa.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Que atividade pode aumentar a emissão de dióxido de carbono?",
        "answers": [
          "Queimar combustíveis fósseis",
          "Usar a luz do dia para ler",
          "Caminhar até um lugar próximo"
        ],
        "correct": 0,
        "why": "A queima de combustíveis fósseis libera dióxido de carbono.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Qual proposta se relaciona ao controle da intensificação do efeito estufa?",
        "answers": [
          "Reduzir emissões e conservar a vegetação",
          "Aumentar queimadas",
          "Queimar mais combustível para criar nuvens"
        ],
        "correct": 0,
        "why": "Reduzir emissões e conservar a vegetação atua sobre causas relacionadas ao problema.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_8",
    "grade": 8,
    "subject": "science",
    "title": "Transformações de energia",
    "skill": "EF08CI03",
    "source_page": 351,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "8º ano",
    "intro": "Equipamentos transformam energia. Identifique a transformação principal desejada em cada uso, lembrando que um equipamento pode produzir mais de um efeito.",
    "questions": [
      {
        "prompt": "Qual é a transformação principal desejada em um ventilador elétrico?",
        "answers": [
          "Elétrica em movimento",
          "Som em alimento",
          "Luz em combustível"
        ],
        "correct": 0,
        "why": "O motor usa energia elétrica para movimentar as pás.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Em um ferro de passar, qual efeito é principalmente desejado?",
        "answers": [
          "Aquecimento a partir de energia elétrica",
          "Produção de gelo",
          "Transformação do tecido em eletricidade"
        ],
        "correct": 0,
        "why": "O ferro transforma energia elétrica em energia térmica para aquecer.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Uma lâmpada acesa ilumina e também aquece. O que isso mostra?",
        "answers": [
          "Pode haver mais de uma transformação de energia",
          "Toda energia vira apenas luz",
          "A energia elétrica deixa de existir sem transformação"
        ],
        "correct": 0,
        "why": "Uma parte da energia aparece como luz e outra como aquecimento.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  },
  {
    "id": "science_9",
    "grade": 9,
    "subject": "science",
    "title": "Mudanças e partículas",
    "skill": "EF09CI01",
    "source_page": 353,
    "source_url": "https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf",
    "band": "9º ano",
    "intro": "Modelos de partículas ajudam a explicar estados físicos. A água continua sendo água ao derreter ou evaporar; mudam a organização, o movimento e as distâncias entre suas moléculas.",
    "questions": [
      {
        "prompt": "O gelo derrete e vira água líquida. Nesse processo físico, as moléculas de água…",
        "answers": [
          "Continuam sendo moléculas de água",
          "Viram moléculas de ferro",
          "Deixam de existir"
        ],
        "correct": 0,
        "why": "Na fusão muda a organização das moléculas, não a identidade da substância.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Comparando vapor e água líquida, qual descrição é compatível com o modelo de partículas?",
        "answers": [
          "No vapor, as moléculas ficam, em média, mais afastadas",
          "No vapor não existem moléculas",
          "No líquido todas as moléculas ficam imóveis"
        ],
        "correct": 0,
        "why": "O estado gasoso apresenta, em média, maior separação entre as moléculas.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      },
      {
        "prompt": "Ao receber energia e aquecer antes de mudar de estado, o que tende a ocorrer com o movimento das partículas?",
        "answers": [
          "Fica mais intenso",
          "Cessa completamente",
          "Transforma todas as partículas em luz"
        ],
        "correct": 0,
        "why": "O aquecimento está associado ao aumento da agitação das partículas, antes da mudança de estado.",
        "hint": "Compare o fenômeno com a explicação da trilha.",
        "reading": ""
      }
    ],
    "coverage": "Recorte de prática; não cobre integralmente a habilidade."
  }
]
