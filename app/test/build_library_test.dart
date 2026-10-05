import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/build_library.dart';

void main() {
  test(
    'Библиотека сохраняет XML, копирует и переименовывает без потери данных',
    () async {
      final dir = await Directory.systemTemp.createTemp('pob-library-');
      addTearDown(() => dir.delete(recursive: true));
      final library = BuildLibrary(dir);
      final source = await library.save(
        'Карты',
        'Искра',
        '<PathOfBuilding2><Tree/><Items/></PathOfBuilding2>',
      );
      final copy = await library.copy(source, '', 'Копия');
      expect(await copy.readAsString(), await source.readAsString());
      final renamed = await library.rename(copy, 'Боссы', 'Искра');
      expect(await copy.exists(), false);
      expect(await renamed.readAsString(), await source.readAsString());
      expect((await library.list()).length, 2);
      await expectLater(
        library.save('Карты', 'Искра', 'replace'),
        throwsA(isA<FileSystemException>()),
      );
      expect(await source.readAsString(), contains('<Tree/>'));
    },
  );
  test('Названия не выходят за каталог библиотеки', () {
    final library = BuildLibrary(Directory('library'));
    for (final name in [
      '../outside',
      '..',
      'CON',
      'AUX.xml',
      'bad.',
      'a/b',
      'a\\b',
      '',
    ]) {
      expect(() => library.destination('', name), throwsFormatException);
    }
    expect(
      () => library.destination('../other', 'build'),
      throwsFormatException,
    );
  });
}
