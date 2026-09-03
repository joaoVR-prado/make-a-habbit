import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/theme/app_fonts.dart';
import 'package:make_a_habbit/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FONTES LOCAIS DO APLICATIVO', () {
    test('Inclui a fonte regular no manifesto do bundle.', () async {
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json'))
              as List<Object?>;
      final families = manifest.cast<Map<String, Object?>>().where(
        (entry) => entry['family'] == AppFonts.family,
      );

      expect(families, hasLength(1));
      expect(families.single['fonts'], [
        {'asset': AppFonts.regularAsset, 'weight': 400},
      ]);
    });

    test(
      'Carrega o TTF empacotado sem acesso HTTP ou cache externo.',
      () async {
        await HttpOverrides.runZoned(
          () async {
            final bytes = await rootBundle.load(AppFonts.regularAsset);
            expect(bytes.lengthInBytes, 566576);
            expect(bytes.getUint32(0), 0x00010000);

            final loader = FontLoader(AppFonts.family)
              ..addFont(Future.value(bytes));
            await loader.load();
          },
          createHttpClient: (_) => throw StateError(
            'O carregamento da fonte não deve acessar a rede.',
          ),
        );
      },
    );

    test('Registra a licença empacotada apenas uma vez.', () async {
      AppFonts.registerLicense();
      AppFonts.registerLicense();

      final entries = await LicenseRegistry.licenses
          .where((entry) => entry.packages.contains(AppFonts.displayName))
          .toList();

      expect(entries, hasLength(1));
      final license = entries.single.paragraphs
          .map((paragraph) => paragraph.text)
          .join('\n');
      expect(license, contains('SIL OPEN FONT LICENSE Version 1.1'));
      expect(license, contains('Copyright 2022'));
    });
  });

  group('PRESERVAÇÃO DA TIPOGRAFIA', () {
    test('Mantém a fonte personalizada nos estilos base.', () {
      final theme = AppTheme.lightTheme.textTheme;
      for (final style in [
        theme.displayLarge,
        theme.displayMedium,
        theme.displaySmall,
        theme.headlineLarge,
        theme.headlineMedium,
        theme.headlineSmall,
        theme.titleSmall,
      ]) {
        expect(style?.fontFamily, AppFonts.family);
      }
    });

    test(
      'Preserva fonte padrão, tamanhos e cores dos estilos sobrescritos.',
      () {
        final theme = AppTheme.lightTheme.textTheme;
        final standardFamily =
            ThemeData.light().textTheme.bodyMedium!.fontFamily;
        final styles = [
          (theme.titleLarge!, 20.0, AppColors.whiteText),
          (theme.titleMedium!, 14.0, AppColors.whiteText),
          (theme.bodyLarge!, 20.0, AppColors.whiteText),
          (theme.bodyMedium!, 16.0, Colors.black),
          (theme.bodySmall!, 8.0, AppColors.whiteText),
          (theme.labelLarge!, 24.0, AppColors.whiteText),
          (theme.labelMedium!, 18.0, AppColors.whiteText),
          (theme.labelSmall!, 12.0, AppColors.whiteText),
        ];
        for (final (style, size, color) in styles) {
          expect(style.fontFamily, standardFamily);
          expect(style.fontSize, size);
          expect(style.color, color);
        }
        expect(theme.titleLarge!.fontWeight, FontWeight.bold);
        expect(theme.bodyLarge!.fontWeight, FontWeight.bold);
        expect(theme.labelMedium!.fontWeight, FontWeight.bold);
      },
    );

    testWidgets('Renderiza o tema e textos acentuados sem rede.', (
      tester,
    ) async {
      await HttpOverrides.runZoned(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Builder(
                  builder: (context) => Column(
                    children: [
                      Text(
                        'Hábitos e conclusões',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Seu progresso',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Hábitos e conclusões'), findsOneWidget);
          expect(find.text('Seu progresso'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        createHttpClient: (_) =>
            throw StateError('A renderização do tema não deve acessar a rede.'),
      );
    });
  });
}
