# Guia técnico

## Ambiente

| Ferramenta | Versão usada |
| :--- | :--- |
| Flutter (canal stable) | 3.50.1 |
| Dart | 3.14.0 |
| Navegador | Chrome ou Edge |

É preciso ter o [Git](https://git-scm.com) e o [Flutter](https://docs.flutter.dev/get-started/install) instalados. Não há variáveis de ambiente, chaves ou servidor.

## Executar do zero

```bash
git clone https://github.com/matheusmontev/ux-flutter-bloco3.git
cd ux-flutter-bloco3
flutter doctor
flutter pub get
flutter run -d chrome
```

Em um celular Android, com o Android SDK instalado e a depuração USB ativa, use `flutter devices` e `flutter run -d <id>`.

## Verificar e gerar a versão web

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

A cada pull request, o GitHub Actions executa a formatação de `lib`, a análise, os testes e o build web.

## Publicar na Vercel

A publicação é manual: o build é feito no computador e o resultado é enviado. É preciso ter o Node.js e acesso ao projeto na Vercel.

```bash
sh tool/publicar.sh
```

## Estrutura do código

```text
lib/
  main.dart        inicialização
  app.dart         tema e estado global
  models/          Activity e UserProfile
  data/            dados simulados do evento fictício
  core/            estado, regras, validações, códigos QR e tema
  features/        uma pasta por área
    auth/  home/  settings/        acesso, início e conta
    schedule/  checkin/            programação e presença
    history/  networking/          certificados e contatos
    shell/                         navegação principal
  widgets/         componentes reutilizados
```

## Decisões de implementação

- **Estado:** um `AppState` (`ChangeNotifier`) é entregue às telas por um `InheritedNotifier`, o `AppScope`. Estado que só interessa a uma tela, como os filtros, fica nela.
- **Regras separadas das telas:** filtros, códigos, validações e certificado ficam em `core/` e são testados sem interface.
- **Persistência:** `shared_preferences` guarda perfil, sessão, presenças, contatos e tema no aparelho. Se os dados estiverem corrompidos, o app volta ao estado inicial.
- **Navegação:** barra inferior em telas estreitas e barra lateral a partir de 840 px.
- **QR Code:** `qr_flutter` gera e `mobile_scanner` lê. O check-in usa `EVENTO:<id>`. O cartão usa `CARTAO:` seguido dos dados em Base64.

## Testes automatizados

| Arquivo | O que verifica |
| :--- | :--- |
| `test/core_test.dart` | Filtros, códigos QR, validações, certificado e formatação |
| `test/app_state_test.dart` | Check-in, contatos, sessão, persistência, troca de conta e dados corrompidos |
| `test/widget_test.dart` | Login, cadastro, estado vazio, check-in até o certificado, saída e layout em 320, 390 e 1280 px |

## Verificações manuais

Preencher somente depois de executar cada item.

| Cenário | Aparelho e navegador | Resultado |
| :--- | :--- | :--- |
| Leitura de QR Code de atividade pela câmera | | pendente |
| Leitura do cartão de outro aparelho | | pendente |
| Câmera com permissão negada | | pendente |
| Dados mantidos após recarregar a página | | pendente |
| Tema escuro e fonte ampliada | | pendente |
| Navegação com leitor de tela | | pendente |

## Limitações conhecidas

- O acesso é simulado: não há autenticação e a senha não é conferida nem guardada.
- Não há servidor. Os dados não passam de um aparelho para outro, exceto o cartão compartilhado.
- O código de check-in é um texto previsível e pode ser digitado fora da sala. Também não há verificação de horário. Um uso real exigiria validação no servidor.
- O certificado é uma demonstração, sem validade e sem exportação em PDF.
- Os contatos são compartilhados pelo QR Code ou pelo código copiado.
- A versão para Android não foi compilada nem testada.

## Identidade visual

- Cores: tinta `#14213D`, azul `#006FA8`, âmbar `#F2A900` (check-in) e fundo `#F7F9F9`. O tema escuro tem tons próprios.
- Fonte: Atkinson Hyperlegible, do Braille Institute, sob a SIL Open Font License (`assets/fonts/OFL.txt`).
- `test/theme_test.dart` confere o contraste mínimo de 4,5:1 nos principais pares de cores.
