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
        final habitsList = providerContainer.read(habitControllerProvider);
        expect(habitsList.length, 1, reason: 'A lista de hábitos agora deve conter 1 tem (novo hábito)');
        expect(habitsList.first.name, newHabit.name, reason: 'O nome do hábito que acabou de ser salvo deve estar correto');

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
        final habistList = providerContainer.read(habitControllerProvider);
        expect(habistList.length, 0, reason: "A lista deve estar vazia após deletar o hábito");

        // Verifica se o repositório foi chamado
        verify(() => mockRepository.deleteHabit(newHabit.id)).called(1);

    });

}