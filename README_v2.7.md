# TacoControl Pro Alpha v2.7

## Decoder binário seguro

A v2.7 reorganiza o tratamento de `.DDD`, `.TGD` e `.C1B` em três estados:

1. **identified** — extensão/formato reconhecido;
2. **partiallyDecoded** — foram encontrados marcadores diagnósticos, sem os transformar em atividades;
3. **decoded** — reservado para um decoder específico que valide a estrutura do formato.

### Regra de segurança
Bytes desconhecidos nunca são convertidos automaticamente em condução, trabalho, descanso, disponibilidade ou pausa.

A classe `TachographBinaryRecord` permite guardar segmentos candidatos com `offset`, `length`, `tag` e bytes brutos para futura análise. Esses segmentos são apenas diagnóstico e não constituem uma interpretação oficial do tacógrafo.

### Próximo passo
Implementar decoders por estrutura/formato, começando pelo DDD, com testes usando ficheiros reais autorizados pelo utilizador. O decoder deve preservar os bytes de origem e só criar `TachographActivity` quando campos, timestamps, códigos de atividade e regras de integridade forem confirmados.

## Limitações
A v2.7 não afirma compatibilidade certificada com todas as gerações de tacógrafos, nem valida assinaturas digitais ou a autenticidade dos ficheiros. O relatório do TacoControl continua sendo auxiliar e não substitui o registo oficial do tacógrafo.
