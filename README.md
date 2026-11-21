# TacoControl Pro — Alpha v1.2

Nesta etapa foram integrados os motores de condução, tempo de trabalho e conformidade ao núcleo local.

## Módulos
- SQLite/Drift
- TimerService
- NotificationService
- DashboardController
- DrivingEngine
- WorkTimeEngine
- ComplianceEngine
- testes unitários iniciais

## Regras de referência
O motor de condução usa como referência as regras europeias: 4h30 de condução antes da pausa, 9h/dia (com extensão para 10h até duas vezes por semana), 56h/semana e 90h em duas semanas.

O motor de tempo de trabalho usa o regime português de 2026: máximo de 60h numa semana e 48h em média num período de quatro meses, sujeito às condições e exceções legais aplicáveis.

## Gerar código Drift e testar
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

A validação jurídica completa, cenários de exceção/derrogação, repousos e integração de notificações em segundo plano ainda devem ser testados antes de uso operacional.


## Sprint 15 — RestEngine + Compliance integration

- Added RestEngine for daily rest classification.
- ComplianceEngine now consumes driving, work-time and rest results.
- Added unit tests for 11h and 9h rest scenarios.
- This is still an Alpha technical build; legal compliance must be validated against the exact driver regime and current legislation before operational use.

## Alpha v0.4 — Dashboard e Alertas

Integra base para estado do Dashboard e AlertEngine com deduplicação e testes.


## Alpha v0.5 — Dashboard em tempo real

- Integração dos motores de condução, trabalho, descanso e conformidade no DashboardController.
- Contadores em tempo real e barras de progresso para condução contínua, diária, semanal, quinzenal e trabalho semanal.
- Alertas locais deduplicados.
- Correção das estruturas de resultados dos motores e testes do AlertEngine.
- Preparado para próxima etapa: histórico editável, relatórios, cálculo real da média de 4 meses e regras avançadas de repouso.

### Referência legal atual
As regras-base usadas nesta versão seguem a Comissão Europeia/Regulamento 561/2006: 4h30 antes da pausa, 9h/dia com extensão até 10h duas vezes por semana, 56h/semana e 90h em duas semanas. O regime português de tempo de trabalho usa 60h semanais e 48h de média em 4 meses, sem contar disponibilidade como tempo de trabalho. Estas regras devem ser validadas para o caso concreto antes de uso operacional.


## Alpha v0.6 — Histórico e edição

- Histórico diário de atividades.
- Seleção de data.
- Edição de tipo, início, fim e observações.
- Exclusão de atividades.
- Acesso ao histórico diretamente no Dashboard.
- Métodos de consulta diária e duração adicionados à base Drift.

### Validação jurídica
As regras de condução usadas como referência continuam a ser 4h30 antes da pausa, 9h/dia (10h até duas vezes por semana), 56h/semana e 90h em duas semanas. O Decreto-Lei n.º 84/2026 estabelece, em Portugal, 60h de trabalho semanal e 48h de média em quatro meses, com disponibilidade excluída do tempo de trabalho. A aplicação continua em Alpha e não substitui o tacógrafo oficial.

## Alpha v0.7 — Relatórios

- Novo ecrã de relatórios dos últimos 7 dias.
- Totais de condução, trabalho e descanso registado.
- Resumo diário.
- Indicador visual de condução face ao limite semanal de referência de 56h.
- Acesso direto aos relatórios a partir do Dashboard.

### Fontes legais consultadas em setembro de 2026
- Comissão Europeia — Driving time and rest periods: 4h30 antes da pausa, 9h/dia (10h duas vezes por semana), 56h/semana e 90h em duas semanas.
- Decreto-Lei n.º 84/2026, de 13 de abril — Portugal: 60h de trabalho semanal e 48h em média em quatro meses; tempo de disponibilidade não é tempo de trabalho.

Esta versão continua em Alpha e não é um substituto do tacógrafo oficial.

## Alpha v0.8 — Regras avançadas de conformidade

- Reforço do cálculo da condução contínua.
- Reconhecimento técnico de pausa de 45 min e de sequência 15 + 30.
- Contagem semanal das extensões de condução acima de 9h, com limite de duas.
- Limites diários, semanais e quinzenais explicitamente expostos no resultado.
- Detecção técnica de repouso diário normal, reduzido e dividido 3h + 9h.
- Contagem de repousos diários reduzidos na semana.
- Preparação do controlo de trabalho noturno (00h–05h), com limite de 10h/24h segundo o regime português aplicável.
- ComplianceEngine atualizado para os novos estados.

### Nota importante
O motor é uma camada de apoio. Casos de derrogação, convenções coletivas, múltiplos empregadores, AETR, ferry/train, emergência, compensação de repouso, condução em equipa e dados incompletos do tacógrafo exigem regras adicionais e validação jurídica antes de uso operacional.

## Alpha v0.8.0 — Legal Rules Hardening

A v0.8 endurece os motores antes da futura integração com tacógrafo: pausa 45 min / 15+30, duas extensões de 10h por semana, limites 56h/90h, repouso 3+9 e contagem de repousos reduzidos. O Dashboard passa a calcular uma média semanalizada real dos últimos quatro meses de atividades registadas, em vez de usar zero por defeito.

## Alpha v0.9
- Simulador de jornada para testar sequências de condução, trabalho e pausas.
- Alertas de 4h15/4h30 e limite diário de condução.
- Acesso ao simulador pelo Dashboard.
- Testes unitários do simulador.


## Alpha v1.0
- Perfil do motorista e veículo persistidos com SharedPreferences.
- Regime principal configurável: Portugal, Espanha ou UE/AETR.
- Preferências de notificações/alertas.
- Acesso às configurações a partir do Dashboard.
- Cartão de estado de conformidade no Dashboard.
- Esta versão continua em Alpha e não substitui o tacógrafo oficial.

## Alpha v1.1
- Novo Modo Motorista com estado PODE CONTINUAR / PLANEIE A PAUSA / PAUSA OBRIGATÓRIA.
- Contadores em tempo real para condução contínua, diária, semanal e duas semanas.
- Atalhos para alteração de atividade e encerramento da jornada.
- Versão do projeto: 1.1.0+11.


## Alpha v1.2 — Resiliência em segundo plano

- Timer baseado no `startTime` persistido, em vez de depender de ticks acumulados.
- Pausa do ticker quando o app entra em segundo plano para reduzir consumo.
- Retoma automática do ticker ao regressar ao app.
- Recalculo dos limites ao voltar ao primeiro plano.
- A jornada ativa continua a ser recuperada a partir da base Drift depois de reabrir o app.
- Respeito à configuração de notificações guardada pelo utilizador.
- Versão `1.2.0+12`.

### Nota técnica
Esta versão melhora a robustez do contador em background, mas não implementa ainda um serviço Android foreground nem garante notificações temporizadas enquanto o processo do sistema estiver completamente encerrado. Essa etapa será tratada separadamente antes da versão de produção.

## Alpha v1.3 — serviço Android em primeiro plano

A v1.3 adiciona uma ponte `MethodChannel` e um serviço Android nativo para manter uma
notificação visível enquanto existe uma jornada ativa. O serviço atualiza o tempo
transcorrido independentemente do ticker do Flutter.

Antes de compilar Android, copie as declarações de `android/foreground_service_manifest.xml`
para o `AndroidManifest.xml` do módulo `app`. O tipo `specialUse` é usado porque o
cronómetro de jornada não é sincronização de dados, localização, mídia ou saúde.

Em Android 14+ os tipos de foreground service e as permissões correspondentes são
obrigatórios. A utilização de `specialUse` também é analisada no Google Play Console.

A v1.3 não implementa reinício automático no boot nem GPS. O serviço deve ser iniciado
pela aplicação enquanto ela está visível, respeitando as restrições do Android para
início de foreground services.

## Alpha v1.5 — GPS integrado ao Modo Motorista

- Atalho para a rota no Modo Motorista.
- Indicador de GPS e distância diretamente no Modo Motorista.
- Novo ecrã de rota com representação visual local dos pontos GPS.
- Distância, velocidade, número de pontos e estado do rastreamento.
- Sem dependência de mapa online ou chave de API nesta etapa.
- Rota continua armazenada localmente e pode ser limpa pelo utilizador.
- Versão `1.5.0+15`.

### Nota Android
Para rastreamento de localização em foreground no Android moderno, o serviço deve declarar o tipo `location` e a permissão `FOREGROUND_SERVICE_LOCATION`. O Android também impõe restrições ao iniciar esse serviço a partir do background; por isso, o início do GPS deve ser feito por ação explícita do utilizador enquanto a app está visível. Consulte a documentação oficial antes da compilação/publicação.

## Alpha v1.7 — rotas por jornada

- Cada jornada concluída pode guardar a rota GPS como um registo separado.
- Histórico local de rotas, com data, horário, duração, distância e número de pontos.
- Visualização de uma rota concluída no mapa sem alterar a rota atual.
- O encerramento da jornada cria o registo da rota e limpa a rota GPS ativa.
- Histórico limitado a 90 jornadas para manter o armazenamento local controlado.
- A rota continua opcional: se o GPS não estiver ativo, nenhuma rota é criada.
- Novo acesso ao Histórico de rotas no Modo Motorista.
- Versão `1.7.0+17`.

### Nota de privacidade
As rotas são guardadas localmente no dispositivo nesta versão. Não existe envio automático para servidor.

### Nota Android/Google Play
A v1.7 mantém a localização como serviço foreground de tipo `location`. Android 14+ exige o tipo de serviço e a permissão `FOREGROUND_SERVICE_LOCATION`, além de permissão de localização em runtime. O início do serviço deve respeitar as restrições de início a partir do background.

## Alpha v1.9 — Reconciliação Tacógrafo × TacoControl
- Comparação de atividades importadas em CSV/JSON com o histórico local.
- Tolerância padrão de 2 minutos para início e fim.
- Identificação de atividades presentes apenas numa das fontes.
- Comparação de totais de condução e trabalho.
- Sem envio automático de dados para servidores.
- Formatos binários `.ddd/.tgd/.c1b` continuam apenas identificados nesta Alpha; não são interpretados como se fossem dados válidos.

## Alpha v2.0
- Centro de análise profissional de ficheiros de tacógrafo.
- Totais por atividade, resumo diário, lacunas e tipos desconhecidos.
- Reconciliação com atividades locais mantida.
- Parser binário DDD/TGD/C1B continua pendente de implementação específica.

## Alpha v2.1
- Inspeção de integridade do ficheiro e SHA-256.
- Preparação de adaptadores para parser binário DDD/TGD/C1B.
- Não declara validação criptográfica nem parsing certificado dos formatos binários.


## Alpha v2.2

Validação da linha temporal: sobreposições, lacunas e tipos desconhecidos antes da análise. Ver README_v2.2.md.

## Alpha v2.3
- Adicionado `tachograph_compliance.dart` para avaliação indicativa de conformidade sobre atividades importadas.
- Adicionado botão `Avaliar conformidade` no centro de importação.
- Mantida a distinção entre dados incompletos/divergências e potenciais incumprimentos.

## Alpha v2.4

Adicionada geração local de relatórios PDF dos dados de tacógrafo analisados.


## v2.5
Reforço do motor de conformidade indicativa, cobertura de referência, trabalho noturno, pausas 15+30 e testes unitários. Ver `README_v2.5.md`.

## Alpha v2.6
Preparação do parser binário de tacógrafo: identificação segura de DDD/TGD/C1B, camada isolada, header/heurística e testes. Ainda sem decodificação estruturada dos registos binários.

## Alpha v2.7
Pipeline binário de tacógrafo reorganizado para identificação, segmentação diagnóstica e futura decodificação específica de DDD/TGD/C1B, sem criar atividades a partir de bytes desconhecidos.


## v3.0
- Análise histórica de 56 dias com calendário diário e indicação de cobertura incompleta.


## v3.1

Análise de 56 dias ligada aos dados importados, estados diários indicativos, detalhe por dia e testes. Ver README_v3.1.md.

## v3.2
Centro de conformidade indicativo, reunindo limites diários, semanais, duas semanas, trabalho e histórico de 56 dias num único ecrã.

## v3.3 — Pausas e descansos
Novo ecrã de análise indicativa de pausas e sequências de condução, ligado à importação do tacógrafo. Ver `README_v3.3.md` para limitações.

## Alpha v3.4

Melhora a análise de pausas: lacunas entre registos não são presumidas como pausas, sobreposições são sinalizadas e a sequência 15+30 é verificada pela ordem dos registos. Ver `README_v3.4.md` para limitações.


## Alpha v3.5.0+35
- Classificação de descansos diários e semanais explicitamente registados.
- Distinção entre descanso normal, reduzido e inferior aos mínimos indicativos.
- Lacunas não são presumidas como descanso.
- Testes unitários para classificações e dados incompletos.
- Limitação: não calcula ainda sequência legal completa, frequência de reduções nem compensações.
