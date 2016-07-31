import 'dart:async';
import 'dart:io';
import 'package:pogogen/pogogen.dart';
import 'package:unscripted/unscripted.dart';

@Command(
    help: 'This tool is meant to generate multiple accounts configurations '
        'for https://github.com/PokemonGoF/PokemonGo-Bot.')
Future<Null> generator(
    {@Option(help: 'Sets the output directory', defaultsTo: 'config', abbr: 'o')
        String output,
    @Option(help: 'Sets the input accounts.json file', defaultsTo: 'config/accounts.json', abbr: 'a')
        String accounts,
    @Option(help: 'Sets the input sample configuration json file', defaultsTo: 'config.json.pokemon.example', abbr: 'i')
        String input}) async {
  final outputDirectory = new Directory(output);
  final accountsFile = new File(accounts);
  final inputFile = new File(input);

  await checkExists(outputDirectory);
  await checkExists(accountsFile);
  await checkExists(inputFile);

  final configGenerator = new ConfigGenerator();
  final configs =
      await configGenerator.generateConfigs(inputFile.path, accountsFile.path);
  await configGenerator.writeConfigs(configs, outputDirectory.path);
}

Future<Null> checkExists(FileSystemEntity entity) async {
  if (!await entity.exists()) {
    throw new ArgumentError.value(entity.path, "No such file or directory");
  }
}

Future main(List<String> args) => new Script(generator).execute(args);