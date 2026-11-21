# TacoControl Pro Alpha v2.1

## Integridade e preparação do parser de tacógrafo

A v2.1 adiciona uma camada de inspeção antes da análise do ficheiro:

- identificação da extensão e tamanho;
- cálculo de SHA-256 do ficheiro original selecionado;
- distinção entre formatos estruturados (CSV/JSON) e binários (.DDD/.TGD/.C1B);
- aviso explícito de que extensões binárias não significam que o conteúdo foi validado;
- base para futuros adaptadores de parser por geração/formato;
- manutenção da análise e reconciliação já existentes.

### Importante sobre DDD/TGD/C1B

O módulo não afirma validar assinaturas digitais, certificados, MACs, ASN.1 ou toda a estrutura binária do tacógrafo. As especificações europeias definem estruturas de cartão e dados, incluindo `Driver_Activity_Data`, `Events_Data`, `Faults_Data`, `Vehicles_Used`, `Places`, `Control_Activity_Data` e `Specific_Conditions`. A implementação completa deve seguir essas especificações e preservar os dados assinados.

### Base técnica oficial

- Regulamento (UE) n.º 165/2014: dados do tacógrafo incluem distância, velocidade, tempo, posição, identidade do condutor, atividade, calibração, eventos e falhas.
- Regulamento de execução (UE) 2016/799: especificações técnicas e estrutura das aplicações dos cartões de tacógrafo, incluindo gerações 1 e 2.
- Regulamento de execução (UE) 2018/502: regras de descarregamento de cartões e ficheiros de dados.

Fontes:
- https://eur-lex.europa.eu/eli/reg/2014/165/oj
- https://eur-lex.europa.eu/eli/reg_impl/2016/799/2016-05-26/eng
- https://eur-lex.europa.eu/eli/reg_impl/2018/502/oj
- https://transport.ec.europa.eu/transport-modes/road/tachograph_en

## Nota

A v2.1 é Alpha. O SHA-256 é apenas uma impressão digital do ficheiro selecionado; não é uma assinatura digital do tacógrafo. O módulo ainda não é um parser/certificador oficial de DDD/TGD/C1B e não substitui o ficheiro original, o tacógrafo ou os sistemas oficiais.
