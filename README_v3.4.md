# TacoControl Pro Alpha v3.4

## Melhorias no analisador de pausas

- A análise de pausas usa apenas atividades explicitamente registadas como pausa.
- Lacunas entre atividades são apresentadas como dados não classificados, nunca presumidas como pausas ou descanso.
- Deteta atividades sobrepostas e alerta que os totais podem estar duplicados.
- Verifica a sequência explícita de pausas para o padrão indicativo 15 + 30 minutos; uma pausa de 30 minutos antes da pausa de 15 minutos não é aceite como sequência válida.
- Mantém a verificação de pausa contínua de 45 minutos e o reinício por atividade explicitamente classificada como descanso.
- A página mostra contagens de sobreposições e lacunas.
- Testes adicionados para lacunas não classificadas e atividades sobrepostas.

## Limitações

Versão Alpha, indicativa. Não certifica conformidade legal, descansos diários ou semanais, compensações, trabalho noturno, exceções, condução em tripulação ou a interpretação de todos os formatos binários de tacógrafo. Os dados importados podem ser incompletos ou incorretos. Validar com registos oficiais e regras aplicáveis.

## Versão

`3.4.0+34`
