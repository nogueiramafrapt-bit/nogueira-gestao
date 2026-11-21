# TacoControl Pro Alpha v1.4 — GPS + Rota

Esta versão adiciona rastreio GPS opcional da jornada.

## Funcionalidades
- pedido de permissão de localização;
- verificação de GPS ligado;
- rastreio contínuo com atualização aproximada a cada 5 segundos e/ou 10 m;
- distância acumulada;
- velocidade atual;
- precisão do sinal;
- latitude/longitude da última posição;
- contagem de pontos;
- armazenamento local da rota em SharedPreferences;
- notificação de foreground durante o rastreio em Android;
- botão para parar e limpar a rota.

## Android
Adicionar ao `android/app/src/main/AndroidManifest.xml`:

- ACCESS_COARSE_LOCATION
- ACCESS_FINE_LOCATION
- FOREGROUND_SERVICE_LOCATION

O Android 14+ exige que um foreground service de localização declare o tipo `location` e a permissão específica `FOREGROUND_SERVICE_LOCATION`. O serviço deve ser iniciado enquanto a aplicação está visível quando depende de permissões de localização durante o uso.

Nesta versão o pedido de `ACCESS_BACKGROUND_LOCATION` não é necessário para iniciar o rastreio: o utilizador ativa o GPS dentro da aplicação e o Geolocator mantém a execução através de uma notificação foreground.

## Privacidade
A rota é mantida localmente. Não existe envio automático para servidor.

## Limitações Alpha
- não há mapa/cartografia ainda;
- não há geocodificação de endereços;
- não há sincronização em nuvem;
- não é uma prova oficial do percurso nem substitui o tacógrafo;
- o cálculo de distância ignora saltos GPS superiores a 2 km entre amostras para evitar distâncias falsas.

## Build
Executar:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Para Android 14+, confirmar que o projeto usa `compileSdk`/target compatível e que as permissões acima foram adicionadas ao Manifest.
