import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_config_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_scheduler_provider.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository{}
class MockConclusionRepository extends Mock implements ConclusionRepository{}
class MockNotificationConfigRepository extends Mock implements NotificationConfigRepository{}
class NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> cancelForHabit(String habitId) async {}
  @override
  Future<bool> isPermissionGranted() async => true;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> replaceSchedules({required HabitModel habit, required bool reminderEnabled, required bool streakEnabled, required DateTime now, int currentStreak = 0}) async {}
}

void main(){
    late MockHabitRepository mockRepository;
    late MockConclusionRepository mockConclusions;
    late MockNotificationConfigRepository mockNotifications;
    late ProviderContainer providerContainer;

    setUp(() async {
        mockRepository = MockHabitRepository();
        mockConclusions = MockConclusionRepository();
        mockNotifications = MockNotificationConfigRepository();

        providerContainer = ProviderContainer(
            overrides: [
                habitRepositoryProvider.overrideWithValue(mockRepository),
                concludedHabitsRepositoryProvider.overrideWithValue(mockConclusions),
                notificationConfigRepositoryProvider.overrideWithValue(mockNotifications),
                notificationSchedulerProvider.overrideWithValue(NoopNotificationScheduler()),
            ]
        );

        when(() => mockRepository.getAll()).thenReturn([]);
        await providerContainer.read(habitControllerProvider.future);

    });

    tearDown((){
        providerContainer.dispose();

    });

    group('TESTES BÁSICOS DE ADIÇÃO, REMOÇÃO E EDIÇÃO DE HÁBITOS', (){
      test('Ao adicionarmos um hábito, a lista de hábitos deve ser atualizada', () async{
          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: DateTime(2026, 01, 24)
          );

          final newNotification = NotificationConfigModel(
            isReminderEnabled: false, 
            isStreakEnabled: false, 
            customTimeNotification: []
          
          );

          when(() => mockRepository.add(newHabit)).thenAnswer((_) async{});
          when(() => mockNotifications.save(newHabit.id, newNotification)).thenAnswer((_) async {});

          final controller = providerContainer.read(habitControllerProvider.notifier);
          await controller.addHabit(newHabit, newNotification);

          // Valida se o estado mudou
          final currentList = providerContainer.read(habitControllerProvider).requireValue;
          expect(currentList.length, 1, reason: 'A lista de hábitos agora deve conter 1 tem (novo hábito)');
          expect(currentList.first.name, newHabit.name, reason: 'O nome do hábito que acabou de ser salvo deve estar correto');
          expect(currentList.first.conclusionType, newHabit.conclusionType, reason: 'O tipo de conclusao do hábito que acabou de ser salvo deve estar correto');
          expect(currentList.first.goalQuantity, newHabit.goalQuantity, reason: 'A meta de conclusão do hábito que acabou de ser salvo deve estar correto');
          expect(currentList.first.frequency.type, newHabit.frequency.type, reason: 'O nome do hábito que acabou de ser salvo deve estar correto');

          // Verifica se o repositório foi chamado
          verify(() => mockRepository.add(newHabit)).called(1);
          verify(() => mockNotifications.save(newHabit.id, newNotification)).called(1);

      });

      test('Ao removermos um hábito, a lista de hábitos deve ser atualizada', () async {
          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: DateTime(2026, 01, 24)
          );

          when(() => mockRepository.getAll()).thenReturn([newHabit]);
          when(() => mockConclusions.deleteByHabit(newHabit.id)).thenAnswer((_) async {});
          when(() => mockNotifications.delete(newHabit.id)).thenAnswer((_) async {});
          when(() => mockRepository.delete(newHabit.id)).thenAnswer((_) async {});

          final controller = providerContainer.read(habitControllerProvider.notifier);
          expect(providerContainer.read(habitControllerProvider).requireValue.length, 1);

          // Deleta o Hábito
          await controller.deleteHabit(newHabit.id);

          // Valida se o estado mudou
          final currentList = providerContainer.read(habitControllerProvider).requireValue;
          expect(currentList.length, 0, reason: "A lista deve estar vazia após deletar o hábito");

          // Verifica se o repositório foi chamado
          verify(() => mockConclusions.deleteByHabit(newHabit.id)).called(1);
          verify(() => mockNotifications.delete(newHabit.id)).called(1);
          verify(() => mockRepository.delete(newHabit.id)).called(1);

      });

      test('Ao editarmos um hábito, os dados do hábito atual devem ser ' 
      'modificados para os novos dados inseridos pelo usuário', () async{
          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: DateTime(2026, 01, 24)
          );

          when(() => mockRepository.getAll()).thenReturn([newHabit]);

          // Usuário edita o hábito, salvando por cima do hábito anterior
          final editedNewHabit = HabitModel(
              id: newHabit.id, 
              iconCode: 1, 
              name: 'Diminuir o café para 4 xícaras ao dia, todos os dias exceto final de semana', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 4, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.weekly,
                  selectedDays: [1, 2, 3, 4, 5]
              ), 
              startDate: DateTime(2026, 01, 24)
          );

          final newNotification = NotificationConfigModel(
            isReminderEnabled: false, 
            isStreakEnabled: false, 
            customTimeNotification: []
          
          );

          when(() => mockRepository.update(editedNewHabit)).thenAnswer((_) async {});
          when(() => mockRepository.getById(editedNewHabit.id)).thenReturn(newHabit);
          when(() => mockNotifications.save(newHabit.id, newNotification)).thenAnswer((_) async {});

          final controller = providerContainer.read(habitControllerProvider.notifier);
          // Verificamos se o estado da lista ainda é o antigo
          expect(providerContainer.read(habitControllerProvider).requireValue.first.name, 'Diminuir o café para 2 xícaras ao dia, todos os dias');
          
          // Edita o hábito
          await controller.updateHabit(editedNewHabit, newNotification);

          final currentList = providerContainer.read(habitControllerProvider).requireValue;
          final habitInCurrentList = currentList.first;

          // Verificamos os campos alterados
          expect(habitInCurrentList.id, equals('1'), reason: 'O id não deve ser alterado');
          expect(habitInCurrentList.iconCode, 1, reason: 'O icone deve ser alterado, de acordo com o que o usuário inseriu');
          expect(habitInCurrentList.name, equals('Diminuir o café para 4 xícaras ao dia, todos os dias exceto final de semana'));
          expect(habitInCurrentList.conclusionType, HabitConclusionType.goalQuantity, reason: 'O método de conclusão do hábito não foi alterado, então deve ser o mesmo');
          expect(habitInCurrentList.goalQuantity, 4, reason: 'Quantidade para concluir o hábito foi alterado');
          expect(habitInCurrentList.frequency.type, HabitFrequencyType.weekly, reason: 'O tipo de frequência deve ser alterado para semanal');
          expect(habitInCurrentList.frequency.selectedDays, equals([1, 2, 3, 4, 5]), reason: 'Os dias do hábito foram alterados');
          expect(habitInCurrentList.startDate, equals(DateTime(2026, 01, 24)));

          // Verifica se o repositório foi chamado
          verify(() => mockRepository.update(editedNewHabit)).called(1);
          verify(() => mockNotifications.save(newHabit.id, newNotification)).called(1);

      });

      test('Ao deletarmos todos os hábitos, a lista de hábitos deve estar vazia', () async {
          final newHabit1 = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: DateTime(2026, 01, 24)
          );

          final newHabit2 = HabitModel(
              id: '2', 
              iconCode: 1, 
              name: 'Fumar cigarro', 
              conclusionType: HabitConclusionType.yesNo,
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: DateTime(2026, 01, 23)
          );

          when(() => mockRepository.getAll()).thenReturn([newHabit1, newHabit2]);
          when(() => mockConclusions.clear()).thenAnswer((_) async {});
          when(() => mockNotifications.clear()).thenAnswer((_) async {});
          when(() => mockRepository.clear()).thenAnswer((_) async {});

          final controller = providerContainer.read(habitControllerProvider.notifier);
          expect(providerContainer.read(habitControllerProvider).requireValue.length, 2);

          // Apaga todos os hábitos
          await controller.clearAllData();

          // Valida se o estado mudou
          final currentList = providerContainer.read(habitControllerProvider).requireValue;
          expect(currentList.length, 0, reason: "A lista deve estar vazia após deletar todos os hábitos");

          // Verifica se o repositório foi chamado
          verify(() => mockConclusions.clear()).called(1);
          verify(() => mockNotifications.clear()).called(1);
          verify(() => mockRepository.clear()).called(1);

      });
    });
    // FIM

    group('TESTES COM BASE NAS DATAS ', (){
      test('Hábitos não devem aparecer no dia atual se a data de inicio ainda não chegou', () async {
        final today = DateTime(2026, 01, 25);
        final tomorrow = today.add(const Duration(days: 1));

        final newHabit = HabitModel(
            id: '1', 
            iconCode: 0, 
            name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
            conclusionType: HabitConclusionType.goalQuantity,
            goalQuantity: 2, 
            frequency: HabitFrequency.fromType(
                type: HabitFrequencyType.daily,
                selectedDays: [1, 2, 3, 4, 5, 6, 7]
            ), 
            startDate: tomorrow
        );

        final isActive = newHabit.isHabitActiveOn(today);
        
        expect(isActive, isFalse, reason: 'Hábitos que ainda não começaram não devem aparecer na lista');

    });

        test('Hábitos não devem aparecer no dia atual se a data de fim já passou', () async {
          final today = DateTime(2026, 01, 25);
          final yesterday = today.subtract(const Duration(days: 1));

          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: yesterday.subtract(const Duration(days: 1)),
              endDate: yesterday
          );

          final isActive = newHabit.isHabitActiveOn(today);
          
          expect(isActive, isFalse, reason: 'Hábitos que já acabaram não devem aparecer na lista');

        });

        test('Hábitos criados com a data de hoje já devem aparecer na lista ', () async {
          final today = DateTime(2026, 01, 25);

          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.daily,
                  selectedDays: [1, 2, 3, 4, 5, 6, 7]
              ), 
              startDate: today,
          );

          final isActive = newHabit.isHabitActiveOn(today);
          
          expect(isActive, isTrue, reason: 'Hábitos criados hoje com a data de inicio para hoje devem aparecer na lista');

        });

        test('Verificamos quais dias o hábito semanal deve aparecer nas datas fornecidas', () async {
          final startDate = DateTime(2026, 01, 25);
          final today = DateTime(2026, 02, 15);
          final tuesday = DateTime(2026, 02, 17);

          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Ler um livro nos dias de descanso', 
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 2, 
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.weekly,
                  selectedDays: [1, 4, 6, 7]
              ), 
              startDate: startDate,
          );

          final isActiveToday = newHabit.isHabitActiveOn(today);
          final isActiveTuesday = newHabit.isHabitActiveOn(tuesday);
          
          expect(isActiveToday, isTrue, reason: 'O usuário criou um hábito que deve aparecer na segunda, quinta, sabado e domingo. Como a data fornecida é domingo, o hábito deve aparecer hoje');
          expect(isActiveTuesday, isFalse, reason: 'O usuário criou um hábito que deve aparecer na segunda, quinta, sabado e domingo. Como a data fornecida é terça, o hábito não deve aparecer');

        });

        test('Verificamos quais dias o hábito mensal deve aparecer, com base nas dastas fornecidas', () async {
          final startDate = DateTime(2026, 01, 25);
          final today = DateTime(2026, 02, 15);
          final lastDayFebruary = DateTime(2026, 02, 28);

          final newHabit = HabitModel(
              id: '1', 
              iconCode: 0, 
              name: 'Fazer trilha', 
              conclusionType: HabitConclusionType.yesNo,
              frequency: HabitFrequency.fromType(
                  type: HabitFrequencyType.monthly,
                  selectedDays: [1, 15, 30]
              ), 
              startDate: startDate,
          );

          final isActiveToday = newHabit.isHabitActiveOn(today);
          final isActiveFebruary = newHabit.isHabitActiveOn(lastDayFebruary);
          
          expect(isActiveToday, isTrue, reason: 'O usuário criou um hábito que deve aparecer no dia 1, 15 e 30 de cada mês. Como a data fornecida é dia 15, o hábito deve aparecer hoje');
          expect(isActiveFebruary, isFalse, reason: 'O usuário criou um hábito que deve aparecer no dia 1, 15 e 30 de cada mês. Como fevereiro não tem dia 30, o hábito não deve aparecer nessa data');

        });
    });
    // FIM

    group('TESTES DE ESTADO DO RASCUNHO', () {
      late ProviderContainer container;

      setUp((){
        container = ProviderContainer();

      });

      tearDown((){
        container.dispose();

      });

        test('O estado inicial do rascunho desve ser vazio', (){
            final draftState = container.read(draftHabitProvider);

            expect(draftState.existingId, isNull, reason: 'O ID ainda não foi criado, então deve estar vazio');
            expect(draftState.name, isEmpty, reason: 'O Nome ainda não foi criado, então deve estar vazio');
            expect(draftState.category, isNull, reason: 'A Categoria ainda não foi criada, então deve estar vazia');
            expect(draftState.conclusionType, isNull, reason: 'O Método de Conclusão ainda não foi criado, então deve estar vazio');
            expect(draftState.isStreakEnabled, isFalse, reason: 'A ofensiva por padrão vem desativada');
            expect(draftState.weeklyDays, isEmpty, reason: 'Não temos um hábito criado, então lógicamente não temos dias selecionados');
            expect(draftState.monthlyDays, isEmpty, reason: 'Não temos um hábito criado, então lógicamente não temos dias selecionados');

        });

        test('O Notifier deve atualizar as propriedades individuais corretamente', (){
            final notifier = container.read(draftHabitProvider.notifier);

            // Criamos um ato de atualização
            notifier.updateName('Beber 2L de água');
            notifier.updateConclusionType(HabitConclusionType.goalQuantity);
            notifier.updateGoalQuantity('2');

            // Lemos a atualização
            final updatedState = container.read(draftHabitProvider);

            // Lemos se a atualização realmente aconteceu e se ela bate com o que foi passado
            expect(updatedState.name, 'Beber 2L de água');
            expect(updatedState.conclusionType, HabitConclusionType.goalQuantity);
            expect(updatedState.goalQuantity, '2');

        });

        test('O método clear() deve limpar todos os valores para o valor inicial', (){
            final notifier = container.read(draftHabitProvider.notifier);

            // Criamos um ato de atualização
            notifier.updateName('Hábito a ser limpo');
            notifier.updateStartDate(DateTime(2026, 05, 31));
            notifier.updateGoalQuantity('2026');

            // Limpamos o hábito
            notifier.clear();

            final clearedState = container.read(draftHabitProvider);

            // Lemos se a limpeza realmente aconteceu
            expect(clearedState.name, isEmpty, reason: 'O nome deve estar vazio');
            // Validamos dia, mes e ano da data de inicio, que deve estar como Datetime.now()
            final today = DateTime.now();
            expect(clearedState.startDate?.day, today.day, reason: 'A data de inicio deve voltar para hoje');
            expect(clearedState.startDate?.month, today.month);
            expect(clearedState.startDate?.year, today.year);

            expect(clearedState.goalQuantity, isEmpty, reason: 'A meta deve estar vazia');

        });

        test('O método loadForEdit() deve preencher o rascunho inteiro com os dados do Hábito', (){
            // Criamos um Hábito
            final habitToEdit = HabitModel(
                id: '999', 
                iconCode: 1, 
                name: 'Ler 10 páginas do Senhor dos Anéis', 
                conclusionType: HabitConclusionType.goalQuantity,
                goalQuantity: 10, 
                frequency: HabitFrequency.fromType(
                    type: HabitFrequencyType.daily,
                    selectedDays: []
                ), 
                startDate: DateTime(2026, 1, 1),
                notificationTime: DateTime(2026, 1, 1, 20, 30)

            );

            final config = NotificationConfigModel(
                isReminderEnabled: true, 
                isStreakEnabled: true, 
                customTimeNotification: []

            );

            final notifier = container.read(draftHabitProvider.notifier);
            
            // Carregamos o hábito e sua configuração de notificação
            notifier.loadForEdit(habitToEdit, config);

            // Lemos o estado
            final loadedState = container.read(draftHabitProvider);

            expect(loadedState.existingId, '999');
            expect(loadedState.name, 'Ler 10 páginas do Senhor dos Anéis');
            expect(loadedState.conclusionType, HabitConclusionType.goalQuantity);
            expect(loadedState.goalQuantity, '10');
     
            expect(loadedState.reminderTime?.hour, 20);
            expect(loadedState.reminderTime?.minute, 30);
            expect(loadedState.isStreakEnabled, isTrue);
                    
        });

    });

}
