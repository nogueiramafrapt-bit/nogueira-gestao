# TacoControl Pro — correções v3.5.1

## Alterações
- Corrigida a deteção de pausa fracionada de condução: 15 minutos primeiro e 30 minutos depois, em blocos contíguos.
- Mantida a contagem de condução acumulada após a pausa qualificada, em vez de a zerar.
- Descansos sobrepostos são agora unidos antes da classificação, evitando dupla contagem.
- Descanso diário fracionado exige a ordem 3h + 9h; 9h + 3h não é aceite.
- Contagem de descansos diários reduzidos passa a considerar o período desde o último descanso semanal registado, com aviso a partir do terceiro.
- O limite de trabalho noturno verifica o total de trabalho num período móvel de 24h associado a trabalho entre 00:00 e 05:00, e não apenas as horas dentro da janela noturna.
- Adicionados testes de regressão para os casos acima.

## Limitações que permanecem
- Os cálculos são indicativos e dependem de registos completos e corretamente classificados.
- A validação integral de janelas móveis legais, compensações de descanso semanal, exceções, trabalho noturno por convenção coletiva e períodos de referência requer revisão jurídica e dados completos.
- A descodificação binária DDD/TGD/C1B continua por implementar e testar com amostras reais.
- Este pacote ainda não inclui `android/gradlew`, Gradle Wrapper completo nem o ficheiro gerado `lib/database/app_database.g.dart`. Para preparar a build local:
  1. `flutter create . --platforms=android`
  2. `flutter pub get`
  3. `dart run build_runner build --delete-conflicting-outputs`
  4. `flutter analyze`
  5. `flutter test`
  6. `flutter build apk --release`

## Estado de validação
O ambiente de trabalho usado para esta correção não tem Flutter/Dart instalados. Por isso, os testes foram adicionados mas **não foram executados**, e não existe APK compilado nesta entrega.
