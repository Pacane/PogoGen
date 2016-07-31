import 'dart:async';
import 'dart:io';
import 'dart:convert';

typedef Map<String, dynamic> ApplyConfig(Map<String, dynamic> originalConfig);

class AccountSettings {
  String username;
  String filename;
  String authService;
  String location;

  AccountSettings.fromMap(Map<String, dynamic> json) {
    username = json['username'];
    filename = json['filename'];
    authService = json['auth_service'];
    location = json['location'];
  }
}

class GlobalSettings {
  String gmapKey;
  String password;
  bool longerEggsFirst;
  bool useLuckyEggs;
  int maxSteps;
  double walkSpeed;
  bool locationCache;

  GlobalSettings.fromMap(Map<String, dynamic> json) {
    gmapKey = json['gmapkey'];
    password = json['password'];
    longerEggsFirst = json['longer_eggs_first'];
    useLuckyEggs = json['use_lucky_eggs'];
    maxSteps = json['max_steps'];
    walkSpeed = json['walk'];
    locationCache = json['location_cache'];
  }
}

Map<String, dynamic> applyAccountSettings(
    Map<String, dynamic> config, AccountSettings account) {
  final newConfig = new Map.from(config) as Map<String, dynamic>;
  newConfig['username'] = account.username;
  newConfig['auth_service'] = account.authService;
  newConfig['location'] = account.location;

  return newConfig;
}

Map<String, dynamic> applyGlobalSettings(
    Map<String, dynamic> config, GlobalSettings global) {
  final newConfig = new Map.from(config) as Map<String, dynamic>;

  newConfig['password'] = global.password;
  newConfig['gmapkey'] = global.gmapKey;
  newConfig['max_steps'] = global.maxSteps;
  newConfig['walk'] = global.walkSpeed;
  newConfig['location_cache'] = global.locationCache;

  final incubateEggsTask = (newConfig['tasks'] as List<Map>)
      .singleWhere((Map m) => m['type'] == 'IncubateEggs');
  incubateEggsTask['config']['longer_eggs_first'] = global.longerEggsFirst;

  final evolveAllTask = (newConfig['tasks'] as List<Map>)
      .singleWhere((Map m) => m['type'] == 'EvolveAll');
  evolveAllTask['config']['use_lucky_egg'] = global.useLuckyEggs;

  return newConfig;
}

class ConfigGenerator {
  JsonEncoder encoder = new JsonEncoder.withIndent('    ');

  Future<Map<String, dynamic>> parseConfig(String configPath) async {
    final configFile = new File(configPath);

    final fileAsString = await configFile.readAsString();
    final jsonConfig = JSON.decode(fileAsString) as Map<String, dynamic>;

    return jsonConfig;
  }

  Future<Map<String, dynamic>> parseAccounts(String accountsFilePath) async {
    final accountsFile = new File(accountsFilePath);

    final fileAsString = await accountsFile.readAsString();
    final accountsJson = JSON.decode(fileAsString);

    return accountsJson;
  }

  Future<Map<AccountSettings, Map<String, dynamic>>> generateConfigs(
      String sampleConfigPath, String accountsFilePath) async {
    final parsedConfig = await parseConfig(sampleConfigPath);
    final jsonAccountsFile = await parseAccounts(accountsFilePath);

    final globalSettings = new GlobalSettings.fromMap(
        jsonAccountsFile['global'] as Map<String, dynamic>);

    final accountsJson =
        jsonAccountsFile['accounts'] as List<Map<String, dynamic>>;

    final result = <AccountSettings, Map<String, dynamic>>{};

    for (final accountJson in accountsJson) {
      final account = new AccountSettings.fromMap(accountJson);
      final withAccountSettings = applyAccountSettings(parsedConfig, account);
      final withGlobalSettings =
          applyGlobalSettings(withAccountSettings, globalSettings);

      result[account] = withGlobalSettings;
    }

    return result;
  }

  Future<Null> writeConfigs(Map<AccountSettings, Map<String, dynamic>> accounts,
      String outputDirectory) async {
    accounts.forEach((AccountSettings account, Map config) async {
      final toWrite = new File('$outputDirectory/${account.filename}.json');
      await toWrite.writeAsString(encoder.convert(config));
    });
  }
}
