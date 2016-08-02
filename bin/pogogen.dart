import 'dart:async';
import 'dart:io';
import 'package:pogogen/pogogen.dart';
import 'package:unscripted/unscripted.dart';
import 'package:path/path.dart' as path;

@Command(
    help: 'This tool is meant to generate multiple accounts configurations '
        'for https://github.com/PokemonGoF/PokemonGo-Bot.')
Future<Null> generator(
    {@Option(help: 'Sets the output directory', defaultsTo: 'configs', abbr: 'o')
        String output,
    @Option(help: 'Sets the input accounts.json file', defaultsTo: 'configs/accounts.json', abbr: 'a')
        String accounts,
    @Option(help: 'Sets the input sample configuration json file', defaultsTo: 'configs/config.json.pokemon.example', abbr: 'i')
        String input}) async {
  final workingDirectoryPath = path.context.current;

  final outputDirectory =
      new Directory.fromUri(path.toUri('$workingDirectoryPath/$output'));
  final accountsFile =
      new File.fromUri(path.toUri('$workingDirectoryPath/$accounts'));
  final inputFile =
      new File.fromUri(path.toUri('$workingDirectoryPath/$input'));

  await checkExists(outputDirectory);
  await checkExists(accountsFile);
  await checkExists(inputFile);

  final configGenerator =
      new ConfigGenerator(inputFile, accountsFile, outputDirectory);
  final configs = await configGenerator.generateConfigs();
  await configGenerator.writeConfigs(configs);
}

Future<Null> checkExists(FileSystemEntity entity) async {
  if (!await entity.exists()) {
    throw new ArgumentError.value(entity.path, "No such file or directory");
  }
}

Future main(List<String> args) => new Script(generator).execute(args);
