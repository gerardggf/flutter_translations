import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';

void main(List<String> arguments) async {
  stdout.write(
      '\nMueve tu archivo ".xlsx" a traducir dentro de la carpeta "input" y renombra el archivo como "translations"\n\n');
  stdout.write(
    '¿En qué formato quires exportar los archivos?\n 0 : ARB\n 1 : JSON\n 2 : TXT\n\n',
  );
  final exportTypeIndex = stdin.readLineSync() ?? '0';
  Directory directory = Directory.current;
  String filePath = '${directory.path}\\input\\translations.xlsx';
  stdout.write(
    'Input: ${directory.path}\\input\\translations.xlsx',
  );

  File file = File(filePath);
  if (file.existsSync()) {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;

    List<String> columnNames =
        sheet.rows.first.map((e) => e?.value.toString() ?? '').toList();
    Map<String, Map<String, String>> translations = {};

    for (int j = 1; j < columnNames.length; j++) {
      String columnName = columnNames[j];
      Map<String, String> columnMap = {};

      for (int i = 0; i < sheet.rows.length; i++) {
        List<String> formatId =
            sheet.rows[i].elementAt(0)?.value.toString().trim().split(' ') ??
                [];

        String key = formatId
            .map(
              (e) =>
                  e.substring(0, 1).toUpperCase() +
                  e.substring(1).toLowerCase(),
            )
            .join()
            .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        print(i);
        print(sheet.rows.length);
        try {
          key = key.substring(0, 1).toLowerCase() + key.substring(1);
        } catch (_) {}

        String cellValue = sheet.rows[i].elementAt(j)?.value.toString() ?? '';
        print(key);
        columnMap[key] = cellValue;
      }

      translations[columnName] = columnMap;
    }

    await exportData(
      translations,
      directory,
      exportTypeIndex,
    );
  }
}

Future<void> exportData(
  Map<String, Map<String, String>> translations,
  Directory directory,
  String exportTypeIndex,
) async {
  for (int i = 0; i < translations.length; i++) {
    final content = translations.values.toList()[i];

    final exportType = () {
      if (exportTypeIndex == '1') {
        return 'json';
      }
      if (exportTypeIndex == '2') {
        return 'txt';
      } else {
        return 'arb';
      }
    }();
    stdout.write(
      'Outputs: ${directory.path}\\outputs\\app_${translations.keys.toList()[i].toLowerCase()}.$exportType',
    );

    String filePath =
        '${directory.path}\\outputs\\app_${translations.keys.toList()[i].toLowerCase()}.$exportType';
    File file = File(filePath);

    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonContent = encoder.convert(content);
    await file
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
