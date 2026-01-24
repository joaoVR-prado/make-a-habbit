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

    test('Ao adicionarmos um hábito, a lista de hábitos deve ser atualizada', () async{
        final newHabit = HabitModel(
            id: '1', 
            iconCode: 0, 
            name: 'Diminuir o café para 2 xícaras ao dia, todos os dias', 
            conclusionType: HabitConclusionType.goalQuantity,
            goalQuantity: 2, 
            frequency: HabitFrequency(
                type: HabitFrequencyType.daily,
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7]
            ), 
            startData: DateTime(2026, 01, 24)
        );

        when(() => mockRepository.addHabit(newHabit)).thenAnswer((_) async{});

        final controller = providerContainer.read(habitControllerProvider.notifier);
        await controller.addHabit(newHabit);

        // Valida se o estado mudou
        final currentList = providerContainer.read(habitControllerProvider);
        expect(currentList.length, 1, reason: 'A lista de hábitos agora deve conter 1 tem (novo hábito)');
        expect(currentList.first.name, newHabit.name, reason: 'O nome do hábito que acabou de ser salvo deve estar correto');

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
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7]
            ), 
            startData: DateTime(2026, 01, 24)
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
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7]
            ), 
            startData: DateTime(2026, 01, 24)
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
                type: HabitFrequencyType.daily,
                daysOfWeek: [1, 2, 3, 4, 5]
            ), 
            startData: DateTime(2026, 01, 24)
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
        expect(habitInCurrentList.frequency.type, HabitFrequencyType.daily, reason: 'O tipo de frequência permanece o mesmo');
        expect(habitInCurrentList.frequency.daysOfWeek, equals([1, 2, 3, 4, 5]), reason: 'Os dias do hábito foram alterados');
        expect(habitInCurrentList.startData, equals(DateTime(2026, 01, 24)));

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
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7]
            ), 
            startData: DateTime(2026, 01, 24)
        );

        final newHabit2 = HabitModel(
            id: '2', 
            iconCode: 1, 
            name: 'Fumar cigarro', 
            conclusionType: HabitConclusionType.yesNo,
            frequency: HabitFrequency(
                type: HabitFrequencyType.daily,
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7]
            ), 
            startData: DateTime(2026, 01, 23)
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
        verify(() => mockRepository.clearAllData()).called(2);

    });


}