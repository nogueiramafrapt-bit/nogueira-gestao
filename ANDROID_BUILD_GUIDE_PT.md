# TacoControl Pro v3.5.2 — Android CI

Este pacote está organizado para ser colocado diretamente na raiz do repositório GitHub.

## Validação automática

1. Carregue o conteúdo desta pasta na raiz do repositório `nogueiramafrapt-bit/TacoControl-Pro`.
2. Faça commit na branch `main` (ou `master`).
3. Abra **Actions → Android build and validation**.
4. Aguarde os passos: dependências, geração Drift, `flutter analyze`, `flutter test` e APK release.
5. Se tudo passar, descarregue o artefacto **TacoControl-Pro-APK-release**.

Se houver falha, descarregue **TacoControl-Pro-validation-logs** e partilhe o log. O workflow não publica nem assina o APK para distribuição: usa assinatura debug para instalação de teste.

## Limites conhecidos

- O código Drift `lib/database/app_database.g.dart` é gerado no CI por `build_runner`.
- O workflow configura `local.properties` e gera o Gradle Wrapper durante a execução.
- Esta sessão não tem Flutter/Dart instalados nem acesso de rede ao GitHub; por isso, não é possível executar a compilação aqui nem confirmar antecipadamente o sucesso dos testes.
- A aplicação ainda precisa de validação em dispositivo Android real, especialmente notificações, serviço em primeiro plano, permissões e comportamento em segundo plano.
