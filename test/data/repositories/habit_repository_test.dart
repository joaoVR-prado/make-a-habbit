import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockHabitRepository extends Mock implements IHabitRepository{}

void main(){
    late MockHabitRepository mockRepository;
    late ProviderContainer providerContainer;

    setUp((){
        mockRepository = MockHabitRepository();

        providerContainer = ProviderContainer(
            overrides: [
                habitRepositoryProvider.overrideWithValue(mockRepository)
            ]
        );

        when(() => mockRepository.getAllHabits()).thenReturn([]);

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
                frequency: HabitFrequency(
                    type: HabitFrequencyType.daily,
                    selectedDays: [1, 2, 3, 4, 5, 6, 7]
                ), 
                startDate: DateTime(2026, 01, 24)
            );

            when(() => mockRepository.addHabit(newHabit)).thenAnswer((_) async{});

            final controller = providerContainer.read(habitControllerProvider.notifier);
            await controller.addHabit(newHabit);

            // Valida se o estado mudou
            final currentList = providerContainer.read(habitControllerProvider);
            expect(currentList.length, 1, reason: 'A lista de hábitos agora deve conter 1 tem (novo hábito)');
            expect(currentList.first.name, newHabit.name, reason: 'O nome do hábito que acabou de ser salvo deve estar correto');
            expect(currentList.first.conclusionType, newHabit.conclusionType, reason: 'O tipo de conclusao do hábito que acabou de ser salvo deve estar correto');
            expect(currentList.first.goalQuantity, newHabit.goalQuantity, reason: 'A meta de conclusão do hábito que acabou de ser salvo deve estar correto');
            expect(currentList.first.frequency.type, newHabit.frequency.type, reason: 'O nome do hábito que acabou de ser salvo deve estar correto');

            // Verifica se o repositório foi chamado
            verify(() => mockRepository.addHabit(newHabit)).called(1);

        });

        test('Ao removermos um hábito, a lista de hábitos deve ser atualizada', () async {
            final newHabit = HabitModel(
                id: '1', 
                iconCode: 0, 
                name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
                conclusionType: HabitConclusionType.goalQuantity,
                goalQuantity: 2, 
                frequency: HabitFrequency(
                    type: HabitFrequencyType.daily,
                    selectedDays: [1, 2, 3, 4, 5, 6, 7]
                ), 
                startDate: DateTime(2026, 01, 24)
            );

            when(() => mockRepository.getAllHabits()).thenReturn([newHabit]);
            when(() => mockRepository.deleteHabit(newHabit.id)).thenAnswer((_) async {}); 

            final controller = providerContainer.read(habitControllerProvider.notifier);
            expect(providerContainer.read(habitControllerProvider).length, 1);

            // Deleta o Hábito
            await controller.deleteHabit(newHabit.id);

            // Valida se o estado mudou
            final currentList = providerContainer.read(habitControllerProvider);
            expect(currentList.length, 0, reason: "A lista deve estar vazia após deletar o hábito");

            // Verifica se o repositório foi chamado
            verify(() => mockRepository.deleteHabit(newHabit.id)).called(1);

        });

        test('Ao editarmos um hábito, os dados do hábito atual devem ser ' 
        'modificados para os novos dados inseridos pelo usuário', () async{
            final newHabit = HabitModel(
                id: '1', 
                iconCode: 0, 
                name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
                conclusionType: HabitConclusionType.goalQuantity,
                goalQuantity: 2, 
                frequency: HabitFrequency(
                    type: HabitFrequencyType.daily,
                    selectedDays: [1, 2, 3, 4, 5, 6, 7]
                ), 
                startDate: DateTime(2026, 01, 24)
            );

            when(() => mockRepository.getAllHabits()).thenReturn([newHabit]);

            // Usuário edita o hábito, salvando por cima do hábito anterior
            final editedNewHabit = HabitModel(
                id: newHabit.id, 
                iconCode: 1, 
                name: 'Diminuir o café para 4 xícaras ao dia, todos os dias exceto final de semana', 
                conclusionType: HabitConclusionType.goalQuantity,
                goalQuantity: 4, 
                frequency: HabitFrequency(
                    type: HabitFrequencyType.weekly,
                    selectedDays: [1, 2, 3, 4, 5]
                ), 
                startDate: DateTime(2026, 01, 24)
            );

            when(() => mockRepository.updateHabit(editedNewHabit)).thenAnswer((_) async {});

            final controller = providerContainer.read(habitControllerProvider.notifier);
            // Verificamos se o estado da lista ainda é o antigo
            expect(providerContainer.read(habitControllerProvider).first.name, 'Diminuir o café para 2 xícaras ao dia, todos os dias');
            
            // Edita o hábito
            await controller.updateHabit(editedNewHabit);

            final currentList = providerContainer.read(habitControllerProvider);
            final habitInCurrentList = currentList.first;

            // Verificamos os campos alterados
            expect(habitInCurrentList.id, equals('1'), reason: 'O id não deve ser alterado');
            expect(habitInCurrentList.iconCode, 1, reason: 'O icone deve ser alterado, de acordo com o que o usuário inseriu');
            expect(habitInCurrentList.name, equals('Diminuir o café para 4 xícaras ao dia, todos os dias exceto final de semana'));
            expect(habitInCurrentList.conclusionType, HabitConclusionType.goalQuantity, reason: 'O método de conclusão do hábito não foi alterado, então deve ser o mesmo');
            expect(habitInCurrentList.goalQuantity, 4, reason: 'Quantidade para concluir o hábito foi alterado');
            expect(habitInCurrentList.frequency.type, HabitFrequencyType.weekly, reason: 'O tipo de frequência permanece o mesmo');
            expect(habitInCurrentList.frequency.selectedDays, equals([1, 2, 3, 4, 5]), reason: 'Os dias do hábito foram alterados');
            expect(habitInCurrentList.startDate, equals(DateTime(2026, 01, 24)));

            // Verifica se o repositório foi chamado
            verify(() => mockRepository.updateHabit(editedNewHabit)).called(1);

        });

        test('Ao deletarmos todos os hábitos, a lista de hábitos deve estar vazia', () async {
            final newHabit1 = HabitModel(
                id: '1', 
                iconCode: 0, 
                name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
                conclusionType: HabitConclusionType.goalQuantity,
                goalQuantity: 2, 
                frequency: HabitFrequency(
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
                frequency: HabitFrequency(
                    type: HabitFrequencyType.daily,
                    selectedDays: [1, 2, 3, 4, 5, 6, 7]
                ), 
                startDate: DateTime(2026, 01, 23)
            );

            when(() => mockRepository.getAllHabits()).thenReturn([newHabit1, newHabit2]);
            when(() => mockRepository.clearAllData()).thenAnswer((_) async {}); 

            final controller = providerContainer.read(habitControllerProvider.notifier);
            expect(providerContainer.read(habitControllerProvider).length, 2);

            // Apaga todos os hábitos
            await controller.clearAllData();

            // Valida se o estado mudou
            final currentList = providerContainer.read(habitControllerProvider);
            expect(currentList.length, 0, reason: "A lista deve estar vazia após deletar todos os hábitos");

            // Verifica se o repositório foi chamado
            verify(() => mockRepository.clearAllData()).called(1);

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
                frequency: HabitFrequency(
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
                frequency: HabitFrequency(
                    type: HabitFrequencyType.daily,
                    selectedDays: [1, 2, 3, 4, 5, 6, 7]
                ), 
                startDate: today,
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
                frequency: HabitFrequency(
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
                frequency: HabitFrequency(
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
                frequency: HabitFrequency(
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

    // TODO: Realizar mais testes

    // TODO: Testar os outros tipos de frequencyType, weekly e monthly


}