# TacoControl Pro Alpha v2.0

## Análise profissional de ficheiros de tacógrafo

A v2.0 acrescenta uma camada de análise sobre os dados normalizados importados pelo módulo de tacógrafo.

### Funcionalidades
- análise cronológica das atividades;
- totais de condução, outros trabalhos, pausas, descanso e disponibilidade;
- resumo diário;
- deteção de lacunas sem atividade no ficheiro;
- aviso de tipos de atividade desconhecidos;
- preparação para análise de janelas de 56 dias;
- reconciliação com os registos locais do TacoControl.

### Formatos
CSV e JSON continuam interpretados nesta Alpha. `.DDD`, `.TGD` e `.C1B` são identificados, mas continuam sem parser binário proprietário nesta versão.

Não se deve assumir que um ficheiro binário foi validado apenas por ter sido selecionado. O parser específico deverá respeitar as especificações técnicas do formato e preservar a integridade/dados assinados.

### Base regulamentar
A Comissão Europeia indica que, desde 31/12/2024, os controlos podem abranger o dia corrente e os 56 dias anteriores. O Regulamento (UE) n.º 165/2014 também prevê o descarregamento dos dados do tacógrafo/cartão sem alteração dos dados armazenados.

Fontes oficiais:
- https://transport.ec.europa.eu/transport-modes/road/mobility-package-i/tachographs/questions-and-answers-tachograph-provisions-mobility-package-1_en
- https://transport.ec.europa.eu/transport-modes/road/tachograph_en
- https://eur-lex.europa.eu/eli/reg/2014/165/oj

## Nota técnica
A v2.0 é uma versão Alpha. A análise é assistiva e não substitui o tacógrafo, os ficheiros originais, os sistemas oficiais ou a análise de conformidade efetuada por autoridades/empresas.
