# TacoControl Pro Alpha v1.6 — Mapa real + rota

'
'## Novidades
'
'- mapa interativo com `flutter_map 8.3.2`;
'
'- cartografia OpenStreetMap;
'
'- rota GPS desenhada como polyline;
'
'- marcador da posição atual;
'
'- botão para centrar a posição;
'
'- distância, pontos e velocidade no topo;
'
'- manutenção do armazenamento local da rota;
'
'- atribuição OpenStreetMap no mapa;
'
'- dependências `flutter_map` e `latlong2`;
'
'- correção do import `dart:async` no Modo Motorista.

'
'## Privacidade
'
'A rota continua guardada localmente. Esta versão não envia coordenadas para um servidor TacoControl.

'
'## Mapas
'
'A visualização utiliza `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. Para produção/Google Play, deve ser revista a política de utilização dos tiles e, se necessário, migrar para um fornecedor adequado ou infraestrutura própria/cache.

'
'## Android
'
'- manter `ACCESS_COARSE_LOCATION`/`ACCESS_FINE_LOCATION`;
'
'- manter `FOREGROUND_SERVICE` e `FOREGROUND_SERVICE_LOCATION` para rastreio em foreground service;
'
'- adicionar `INTERNET`.

'
'## Build
'
'```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

'
'## Limitações Alpha
'
'- não existe ainda histórico de rotas separado por jornada;
'
'- não existe navegação curva-a-curva;
'
'- não há geocodificação de endereços;
'
'- a disponibilidade de tiles depende de ligação à Internet;
'
'- não substitui o tacógrafo oficial.
