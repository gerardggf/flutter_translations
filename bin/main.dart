import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  stdout.write(
    'In which format do you want to export the translations?\n 0 : ARB\n 1 : JSON\n 2 : TXT\n\n',
  );
  final exportTypeIndex = stdin.readLineSync() ?? '1';
  Directory directory = Directory.current;
  String filePath = '${directory.path}\\input\\translations.txt';
  stdout.write(
    'Input: ${directory.path}\\input\\translations.txt',
  );

  File file = File(filePath);
  if (file.existsSync()) {
    var fileData = File(filePath).readAsLinesSync()
      ..removeWhere((e) => e.replaceAll(' ', '').isEmpty || e.startsWith('//'));
    Map<String, Map<String, String>> translations = {};
    final languagesIndex = fileData
        .where(
          (e) => e.replaceAll(' ', '').startsWith('-'),
        )
        .toList()
        .map(
          (e) => fileData.indexOf(e),
        )
        .toList()
      ..add(fileData.length);
    final translationKeys = fileData
        .sublist(
          languagesIndex[0],
          languagesIndex[1],
        )
        .map(
          (e) => _formatTranslationKey(e),
        );
    for (int i = 0; i < languagesIndex.length - 1; i++) {
      final data = fileData.sublist(
        languagesIndex[i],
        languagesIndex[i + 1],
      );
      final translationValues = {
        for (int i = 1; i < data.length; i++)
          translationKeys.toList()[data.indexOf(data[i])]: data[i],
      };

      translations.addAll(
        {
          fileData[languagesIndex[i]]
              .replaceAll(' ', '')
              .replaceAll(':', '')
              .replaceAll('-', ''): translationValues,
        },
      );
    }
    await exportData(
      translations,
      directory,
      exportTypeIndex,
    );
  }
  stdout.write(
    '\n\nPulsa cualquier tecla para cerrar.',
  );
  stdin.readLineSync();
}

String _formatTranslationKey(String translation) {
  List<String> words = translation.split(' ');

  words[0] = words.first.toLowerCase();
  for (int i = 1; i < words.length; i++) {
    String word = words[i];
    if (word.isNotEmpty) {
      words[i] = word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
  }
  return words.join('');
}

Future<void> exportData(
  Map<String, Map<String, String>> translations,
  Directory directory,
  String exportTypeIndex,
) async {
  Directory('${directory.path}\\outputs\\').listSync().forEach(
    (FileSystemEntity entidad) {
      if (entidad is File) {
        entidad.deleteSync();
        //print('Archivo borrado: ${entidad.path}');
      }
    },
  );
  for (int i = 0; i < translations.length; i++) {
    final content = translations.values.toList()[i];

    final exportType = () {
      if (exportTypeIndex == '1') {
        return 'json';
      } else if (exportTypeIndex == '2') {
        return 'txt';
      } else {
        return 'arb';
      }
    }();
    stdout.write(
      '\nOutputs: ${directory.path}\\outputs\\app_${translations.keys.toList()[i].toLowerCase()}.$exportType',
    );

    String outputFilePath =
        '${directory.path}\\outputs\\app_${translations.keys.toList()[i].toLowerCase()}.$exportType';
    File outputFile = File(outputFilePath);

    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonContent = encoder.convert(content);
    await outputFile
        .writeAsString(jsonContent)
        .then(
          (file) => stdout.write(
            '\n$file : Archivo creado y escrito de forma exitosa.',
          ),
        )
        .catchError(
          (error) => stdout.write(
            '\nError al crear y escribir el archivo: $error',
          ),
        );
  }
}
