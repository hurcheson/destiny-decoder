import 'package:destiny_decoder_app/features/decode/domain/decode_result.dart';
import 'package:destiny_decoder_app/features/history/data/history_local_source.dart';
import 'package:destiny_decoder_app/features/history/data/history_repository.dart';
import 'package:destiny_decoder_app/features/history/presentation/history_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

DecodeResult _sampleResult(String name) {
  return DecodeResult(
    input: DecodeInput(fullName: name, dateOfBirth: '1990-01-01'),
    core: {'soul_number': 1},
    lifeSeal: LifeSealInterpretation(
      number: 1,
      planet: 'Sun',
      content: {'summary': 'Life seal summary'},
    ),
    soulNumber: SoulNumberInterpretation(
      number: 1,
      content: {'summary': 'Soul number summary'},
    ),
    personalityNumber: SoulNumberInterpretation(
      number: 2,
      content: {'summary': 'Personality summary'},
    ),
    personalYear: LifeSealInterpretation(
      number: 3,
      planet: 'Moon',
      content: {'summary': 'Personal year summary'},
    ),
    pinnacles: [
      LifeSealInterpretation(
        number: 4,
        planet: 'Mars',
        content: {'summary': 'Pinnacle summary'},
      ),
    ],
  );
}

void main() {
  late HistoryLocalSource localSource;
  late HistoryRepository repository;
  late HistoryController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    localSource = HistoryLocalSource();
    repository = HistoryRepository(localSource);
    controller = HistoryController(repository);
  });

  test('addFromResult stores entry and updates state', () async {
    await controller.refresh();

    await controller.addFromResult(_sampleResult('Test User'));

    final state = controller.state.value!;
    expect(state.length, 1);
    expect(state.first.result.input.fullName, 'Test User');

    final stored = await localSource.loadEntries();
    expect(stored.length, 1);
    expect(stored.first.result.input.fullName, 'Test User');
  });

  test('delete removes entry by id', () async {
    await controller.refresh();
    await controller.addFromResult(_sampleResult('Delete Me'));
    final id = controller.state.value!.first.id;

    await controller.delete(id);

    expect(controller.state.value, isEmpty);
    final stored = await localSource.loadEntries();
    expect(stored, isEmpty);
  });

  test('clear removes all entries', () async {
    await controller.refresh();
    await controller.addFromResult(_sampleResult('First'));
    await controller.addFromResult(_sampleResult('Second'));

    await controller.clear();

    expect(controller.state.value, isEmpty);
    final stored = await localSource.loadEntries();
    expect(stored, isEmpty);
  });
}
