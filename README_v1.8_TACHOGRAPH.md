# TacoControl Pro Alpha v1.8 — Centro de dados do tacógrafo

Esta versão cria a primeira camada de **importação de dados**, sem fingir que o telefone já lê diretamente o cartão/tacógrafo.

## O que existe
- Seleção de ficheiros `.csv`, `.json`, `.ddd`, `.tgd` e `.c1b`.
- CSV e JSON: parser experimental para atividades com `start,end,type`.
- Formatos binários: identificação e aviso, sem alterar ou interpretar o conteúdo.
- Dados importados ficam em memória nesta Alpha; persistência e reconciliação com o histórico entram no próximo módulo.

## Formatos CSV/JSON de teste
CSV:
`2026-09-21T08:00:00,2026-09-21T12:00:00,driving`

JSON:
`{"activities":[{"start":"2026-09-21T08:00:00","end":"2026-09-21T12:00:00","type":"driving"}]}`

## Importante
Os dados oficiais do tacógrafo continuam sendo a referência. A Comissão Europeia indica que o cartão do motorista armazena a atividade e que os registos exigidos em fiscalização abrangem o dia atual e os 56 dias anteriores. O TacoControl é uma ferramenta de apoio e não substitui o tacógrafo oficial.
