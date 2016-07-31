import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:pogogen/pogogen.dart';
import 'package:test/test.dart';

String context = path.context.current;
String workingDirectoryPath = '$context/test';
String sampleConfigPath = '$workingDirectoryPath/config.json.pokemon.example';
String accountsFilePath = '$workingDirectoryPath/accounts.json';
ConfigGenerator generator;

Future<Null> clearTestFiles(List<String> filenames) async {
  for (final filename in filenames) {
    final file = new File('$workingDirectoryPath/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }
}

void main() {
  setUp(() {
    generator = new ConfigGenerator();
  });

  tearDown(() async {
    await clearTestFiles(['sample_filename.json', 'sample_filename2.json']);
  });

  test('should be able to parse login information', () async {
    var config = await generator.parseConfig(sampleConfigPath);

    expect(config['auth_service'], isNotNull);
    expect(config['username'], isNotNull);
    expect(config['password'], isNotNull);
    expect(config['gmapkey'], isNotNull);
    expect(config['location'], isNotNull);
  }, skip: false);

  test('should apply global and account settings', () async {
    var config =
        await generator.generateConfigs(sampleConfigPath, accountsFilePath);

    expect(config.keys.length, 2);
    var firstAccount = config.keys.first;
    var firstConfig = config[firstAccount];

    expect(firstConfig['auth_service'], 'sample_auth_service');
    expect(firstConfig['username'], 'sample_username');
    expect(firstConfig['password'], 'sample_password');
    expect(firstConfig['location'], 'someX,someY');
    expect(firstConfig['gmapkey'], 'sample_gmapkey');
    expect(firstConfig['location_cache'], isFalse);
    expect(firstConfig['max_steps'], 12);
    expect(firstConfig['walk'], 4.16);

    final incubateTask = getTaskConfig(incubateTaskName, firstConfig);
    expect(incubateTask['longer_eggs_first'], isFalse);

    final evolveAllTask = getTaskConfig(evolveAllTaskName, firstConfig);
    expect(evolveAllTask['use_lucky_egg'], isFalse);
  });

  test('should write each configs with the correct name and content', () async {
    var config =
        await generator.generateConfigs(sampleConfigPath, accountsFilePath);

    generator.writeConfigs(config, workingDirectoryPath);
  });
}
