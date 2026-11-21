# TacoControl Pro Alpha v3.1

## Histórico de 56 dias ligado ao ficheiro importado

Esta versão liga a análise de 56 dias diretamente às atividades carregadas no Centro de Dados do Tacógrafo.

### Novidades
- Botão **Analisar histórico dos 56 dias** após uma importação.
- Estado diário indicativo:
  - 🟢 Normal pelos critérios implementados
  - 🟡 Atenção / confirmar contexto
  - 🔴 Possível incumprimento — rever
  - ⚪ Dados insuficientes
- Indicadores diários para:
  - condução acima de 9h e 10h;
  - mais de duas extensões de 9h na mesma semana;
  - condução semanal acima de 56h;
  - trabalho semanal acima de 60h.
- Detalhe de cada dia com linha temporal importada.
- Identificação de sobreposições e lacunas sem as converter automaticamente em infrações.
- Testes unitários para a análise de 56 dias.

## Limitações
A análise é indicativa e depende da qualidade/cobertura dos dados importados. Não substitui o tacógrafo oficial, o cartão de condutor, o empregador, a convenção coletiva aplicável ou a autoridade competente.

A extensão diária acima de 9h até 10h exige contexto legal; a aplicação não assume automaticamente que uma extensão é ilícita.
