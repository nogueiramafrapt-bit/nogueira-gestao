# TacoControl Pro Alpha v2.3

## Motor de conformidade sobre dados importados

Esta versão adiciona uma camada indicativa de análise de conformidade sobre atividades importadas e validadas.

Critérios-base implementados:
- condução diária: 9h, com referência à extensão de 10h;
- condução semanal: 56h;
- condução em duas semanas: 90h;
- pausa após 4h30 e análise da maior sequência contínua identificável;
- trabalho semanal: 60h;
- média semanal de trabalho calculada a partir das semanas disponíveis;
- alerta para ficheiros com menos de 56 dias;
- alerta quando o período disponível não cobre quatro meses para concluir a média legal de 48h;
- sinalização do trabalho que cruza 00:00–05:00 para revisão do limite específico de 10h/24h.

A análise é indicativa. Não substitui o tacógrafo oficial, os dados certificados, uma convenção coletiva aplicável ou a decisão da autoridade fiscalizadora.
