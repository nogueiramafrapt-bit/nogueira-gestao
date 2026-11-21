# TacoControl Pro — Alpha v2.5

## Qualidade do motor de conformidade

A v2.5 reforça a camada indicativa de análise de tacógrafo:

- cálculo de cobertura em dias;
- referência de quatro meses tratada por meses de calendário;
- média semanal incluindo semanas sem trabalho dentro da janela analisada;
- deteção de mais de duas extensões acima de 9h de condução na mesma semana;
- condução diária acima de 10h como ocorrência objetiva;
- identificação de trabalho entre 00:00 e 05:00 sem transformar automaticamente esse facto em incumprimento;
- maior rigor na sequência de pausa 15 + 30;
- informação de cobertura e trabalho noturno no relatório/UI;
- testes unitários para limites de 56h, 90h, 60h, cobertura, trabalho noturno e pausa 15+30.

### Limitações

A camada continua indicativa. Não substitui o tacógrafo oficial, a análise integral do cartão/veículo ou a interpretação da legislação e convenção coletiva aplicáveis.

O parser binário DDD/TGD/C1B ainda não está implementado; a extensão pode ser reconhecida e o ficheiro inspecionado, mas a interpretação binária real é uma etapa futura.

O projeto não foi compilado neste ambiente porque o SDK Flutter não está instalado.
