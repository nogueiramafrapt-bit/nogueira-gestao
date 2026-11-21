# TacoControl Pro Alpha v2.2

## Validação da linha temporal do tacógrafo

A v2.2 acrescenta uma etapa de validação antes de confiar nos cálculos do ficheiro importado.

### Novidades
- normalização cronológica das atividades;
- deteção de sobreposições entre atividades;
- deteção de lacunas entre atividades;
- identificação de tipos vazios/desconhecidos;
- cálculo do tempo total de sobreposição;
- cálculo do tempo total de lacunas;
- resumo visual da consistência da linha temporal;
- mantém análise, reconciliação e SHA-256 da v2.1.

### Objetivo
A aplicação passa a distinguir três estados:
1. ficheiro selecionado;
2. atividades estruturadas/importadas;
3. linha temporal validada para análise.

Isto reduz o risco de calcular limites legais sobre dados duplicados, sobrepostos ou incompletos.

### Limitação
A v2.2 ainda não é um parser oficial/certificado de DDD, TGD ou C1B. O ficheiro original deve ser preservado. A validação temporal é uma camada de consistência, não uma validação criptográfica do tacógrafo.
