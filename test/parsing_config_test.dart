import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:pogogen/pogogen.dart';
import 'package:test/test.dart';

String context = path.context.current;
Directory workingDirectory = new Directory('$context/test');
File sampleConfig =
    new File('${workingDirectory.path}/config.json.pokemon.example');
File accountsFile = new File('${workingDirectory.path}/accounts.json');
ConfigGenerator generator;
Map<AccountSettings, Map<String, dynamic>> configs;

Map<String, dynamic> get firstConfig {
  var firstAccount = configs.keys.first;
  var firstConfig = configs[firstAccount];
  return firstConfig;
}

Future<Null> clearTestFiles(List<String> filenames) async {
  for (final filename in filenames) {
    final file = new File('${workingDirectory.path}/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }
}

void main() {
  setUp(() async {
    generator =
        new ConfigGenerator(sampleConfig, accountsFile, workingDirectory);

    configs = await generator.generateConfigs();
  });

  tearDown(() async {
    await clearTestFiles([
      'sample_filename.json',
      'sample_filename2.json',
      'sample_filename3.json'
    ]);
  });

  test('should be able to parse login information', () async {
    var config = await generator.parseConfig(sampleConfig);

    expect(config['auth_service'], isNotNull);
    expect(config['username'], isNotNull);
    expect(config['password'], isNotNull);
    expect(config['gmapkey'], isNotNull);
    expect(config['location'], isNotNull);
  });

  test('should apply global and account settings', () async {
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

  test('should overwrite global password when account password is set',
      () async {
    var secondAccount = configs.keys.last;
    var config = configs[secondAccount];

    expect(config['password'], 'overwritten');
  });

  test("shouldn't produce config for disabled account", () async {
    expect(configs.keys, hasLength(2));
  });

  test("removeSpiral should remove the task completely", () async {
    var tasks = firstConfig['tasks'] as List<Map>;

    expect(tasks.any((Map m) => m['type'] == followSpiralTaskName), isFalse);
  });

  test("remove crap pokemons remove B-grade but not others from release",
      () async {
    var release = firstConfig['release'] as Map<String, dynamic>;

    expect(release['Lapras'], isNotNull);
    expect(release['Golbat'], isNull);
  });

  group('release_any_rule', () async {

  });

  test('release_any_rule should overwrite the "any" release rule', () async {
    var release = firstConfig['release'] as Map<String, dynamic>;

    var expected = {
      "release_below_cp": 600,
      "release_below_iv": 0.85,
      "logic": "and"
    };

    expect(release['any'], expected);
  });
}
