# Make a Habbit

**Make a Habbit** é um aplicativo mobile multiplataforma para **criar, acompanhar e concluir hábitos** no dia a dia. O projeto oferece fluxo de cadastro guiado (categoria, tipo de conclusão, frequência, datas e lembretes), armazenamento local dos dados, calendário na tela inicial e integração com notificações para lembretes de hábitos.

> **Aviso:** este repositório está em **desenvolvimento ativo (Work in Progress)**. APIs, modelos de dados e telas podem mudar sem aviso prévio até uma versão estável.

---

## Tecnologias

| Área | Tecnologias |
|------|-------------|
| **Framework** | [Flutter](https://flutter.dev/) (Dart SDK `^3.10.4`) |
| **Estado** | [Riverpod](https://riverpod.dev/) (`flutter_riverpod`) |
| **Persistência** | [Hive CE](https://github.com/hive-ce/hive_ce) (`hive_ce`, `hive_ce_flutter`) + adapters gerados |
| **Identificadores** | `uuid` |
| **UI** | Material Design, `google_fonts`, `smooth_page_indicator` |
| **Notificações locais** | `awesome_notifications` |
| **Internacionalização** | `flutter_localizations` (locale **pt-BR**) |
| **Testes** | `flutter_test`, `mocktail` |
| **Qualidade** | `flutter_lints` |
| **Geração de código** | `build_runner`, `hive_ce_generator` (modelos Hive) |

---

## Pré-requisitos

- **[Flutter](https://docs.flutter.dev/get-started/install)** instalado e no `PATH` (canal estável recomendado).
- **Dart** (incluído no SDK do Flutter).
- Um **emulador Android**, **simulador iOS** (macOS) ou **dispositivo físico** com depuração USB ativada.
- Para **build iOS**: Xcode e CocoaPods (apenas em macOS).
- **Android Studio** ou **VS Code / Cursor** com extensão Flutter (opcional, mas recomendado).

Verifique o ambiente:

```bash
flutter doctor -v
```

---

## Instalação e uso

Na raiz do repositório:

```bash
git clone <url-do-repositório>
cd make_a_habbit
flutter pub get
```

Se alterar anotações Hive ou modelos com `part '*.g.dart'`, regenere os adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Execute o app em modo debug (escolha o dispositivo quando solicitado):

```bash
flutter run
```

---

## Scripts e comandos úteis

| Objetivo | Comando |
|----------|---------|
| Instalar dependências | `flutter pub get` |
| Executar em desenvolvimento | `flutter run` |
| Análise estática / lints | `flutter analyze` |
| Testes automatizados | `flutter test` |
| Build APK (release) | `flutter build apk` |
| Build App Bundle (Play Store) | `flutter build appbundle` |
| Build iOS | `flutter build ios` (macOS) |
| Regenerar código (Hive, etc.) | `dart run build_runner build --delete-conflicting-outputs` |

---

## Estrutura de pastas (resumo)

```
lib/
├── main.dart                 # Entrada: Hive, notificações, MaterialApp, locale pt-BR
├── core/                     # Tema, cores, enums compartilhados
├── controllers/              # Controllers Riverpod (hábitos, conclusões, notificações)
├── data/
│   ├── models/               # Modelos Hive (hábitos, frequência, conclusões, notificações)
│   ├── providers/            # Providers dos repositórios
│   └── repositories/         # Acesso às boxes Hive
└── presentation/             # Telas e widgets (home, criação/edição de hábitos, comuns)
test/                         # Testes (ex.: repositório de hábitos)
```

---

## Roadmap / To-Do

Visão geral do que já existe no código e do que ainda está planejado ou incompleto.

- [x] Persistência local de hábitos e conclusões (Hive)
- [x] Fluxo multi-etapas para **criar** hábito (nome, tipo de conclusão, frequência, datas, lembrete)
- [x] Tipos de conclusão: **Sim/Não** e **por quantidade** (meta numérica)
- [x] Frequências: **diária**, **dias específicos da semana**, **dias específicos do mês**
- [x] Frequência **“X vezes por semana”**
- [x] **Editar** hábito em andamento (fluxo de edição a partir do diálogo na lista)
- [x] Marcar conclusões por data e listagem no calendário / home
- [x] Notificações locais para lembretes (`awesome_notifications`)
- [ ] **RF-01 / §4.3** — Tela de **relatórios de hábitos**: listagem, filtros, métricas por hábito, calendário mensal e estados vazios (RN-01 / RN-02)
- [ ] Ícone dedicado para o canal de notificações Android 
- [ ] Cobertura de testes e builds de release documentados em CI

---

### 3.1 Funcionalidades principais

Lista em alto nível, alinhada ao escopo do produto e às regras de **relatórios (RF-01 / §4.3)**.

**Cadastro e hábitos**

- [x] Permite ao usuário criar um hábito personalizado.
- [x] Permite ao usuário selecionar os dias em que deseja aplicar o hábito: **todos os dias**, **dias específicos da semana** e **dias específicos do mês**. *(Pendente na UI: **X vezes por semana**.)*
- [x] Permite criar hábitos com formas distintas de conclusão: por **quantidade** (ex.: meta diária) e **Sim/Não**.
- [x] Permite ao usuário **editar** um hábito em andamento.

**Relatórios de hábitos (RF-01)**

- [x] Ao abrir o app, a **primeira tela** é a **home** com a **listagem de hábitos** (fluxo básico).
- [x] Barra de navegação inferior com acesso à aba **Relatórios** *(estrutura de navegação; conteúdo da tela ainda em construção)*.
- [ ] **Relatórios gerais:** lista de **hábitos em andamento** e **filtros** para localizar cada hábito — por **nome**, **data de início**, **data de fim**, **concluídos**, **data de conclusão** e **maior quantidade de dias** em que o hábito está ativo.
- [ ] Ao tocar no **card** de um hábito: **diálogo de detalhe** com **contagem de dias com sucesso**, **contagem de dias sem sucesso**, **taxa de sucesso**, **último dia com sucesso** e **último dia sem sucesso**.
- [ ] No detalhe, **aba de calendário** do **mês atual**: dias com conclusão bem-sucedida em **verde** e sem sucesso em **vermelho**; ao tocar em um dia, **mini diálogo** com a resposta de **“Foi concluído com sucesso?”** ou **QTD** e **Motivo**.
- [ ] **RN-01:** sem hábitos cadastrados — exibir **ícone** e texto: *“Nenhum hábito cadastrado! Comece um agora mesmo na tela de hábitos”*.
- [ ] **RN-02:** filtro aplicado sem resultados — mesma mensagem de estado vazio (*“Nenhum hábito cadastrado! Comece um agora mesmo na tela de hábitos”*), conforme especificação.

---

**Licença / publicação:** conforme `pubspec.yaml` (`publish_to: 'none'`). Ajuste quando houver definição de licença e distribuição.
