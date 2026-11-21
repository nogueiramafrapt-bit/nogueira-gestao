# TacoControl Pro Alpha v2.6

## Parser binário — camada de preparação

A v2.6 cria uma camada isolada para identificação segura de ficheiros `.DDD`, `.TGD` e `.C1B`.

### O que foi acrescentado
- `TachographBinaryParser` como camada independente.
- Identificação do formato pela extensão.
- Leitura segura de tamanho e primeiros bytes (header).
- Indicador heurístico de conteúdo binário plausível.
- Resultado explícito `decoded: false` enquanto não existir decoder real.
- Testes unitários para DDD/TGD.
- Importação mantém lista de atividades vazia para formatos binários ainda não decodificados.

### Importante
Esta camada **não é um parser DDD/TGD/C1B completo** e não valida assinaturas digitais, certificados ou integridade criptográfica específica do formato. O objetivo é impedir que o aplicativo transforme bytes desconhecidos em atividades ou conclusões de conformidade.

## Próxima etapa
Implementar adapters específicos por formato, com testes sobre ficheiros de referência, antes de alimentar o motor de conformidade.
