import 'dart:async';
import 'dart:io';
import 'dart:convert';

const String incubateTaskName = 'IncubateEggs';
const String evolveAllTaskName = 'EvolveAll';
const String followSpiralTaskName = 'FollowSpiral';

class AccountSettings {
  String username;
  String password;
  String filename;
  String authService;
  String location;
  bool enabled;

  AccountSettings.fromMap(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    filename = json['filename'];
    authService = json['auth_service'];
    location = json['location'];
    enabled = json['enabled'];
  }
}

class GlobalSettings {
  String gmapKey;
  String password;
  bool longerEggsFirst;
  bool useLuckyEgg;
  int maxSteps;
  double walkSpeed;
  bool locationCache;
  bool removeSpiral;

  GlobalSettings.fromMap(Map<String, dynamic> json) {
    gmapKey = json['gmapkey'];
    password = json['password'];
    longerEggsFirst = json['longer_eggs_first'];
    useLuckyEgg = json['use_lucky_egg'];
    maxSteps = json['max_steps'];
    walkSpeed = json['walk'];
    locationCache = json['location_cache'];
    removeSpiral = json['remove_spiral'];
  }
}

Map<String, dynamic> applyAccountSettings(
    Map<String, dynamic> config, AccountSettings account) {
  final newConfig = new Map.from(config) as Map<String, dynamic>;
  newConfig['username'] = account.username;
  newConfig['auth_service'] = account.authService;
  newConfig['location'] = account.location;

  if (account.password != null) {
    newConfig['password'] = account.password;
  }

  return newConfig;
}

Map<String, dynamic> applyGlobalSettings(
    Map<String, dynamic> config, GlobalSettings global) {
  final newConfig = new Map.from(config) as Map<String, dynamic>;

  if (global.password != null) {
    newConfig['password'] = global.password;
  }

  newConfig['gmapkey'] = global.gmapKey;
  newConfig['max_steps'] = global.maxSteps;
  newConfig['walk'] = global.walkSpeed;
  newConfig['location_cache'] = global.locationCache;

  final tasks = newConfig['tasks'] as List<Map>;

  final incubateEggsTask =
      (tasks).singleWhere((Map m) => m['type'] == incubateTaskName);
  incubateEggsTask['config']['longer_eggs_first'] = global.longerEggsFirst;

  final evolveAllTask =
      (tasks).singleWhere((Map m) => m['type'] == evolveAllTaskName);
  evolveAllTask['config']['use_lucky_egg'] = global.useLuckyEgg;

  tasks.removeWhere((Map m) => m['type'] == followSpiralTaskName);

  return newConfig;
}

class ConfigGenerator {
  File sampleConfig;
  File accountsFile;
  Directory outputDirectory;
  JsonEncoder encoder = const JsonEncoder.withIndent('    ');

  ConfigGenerator(this.sampleConfig, this.accountsFile, this.outputDirectory);

  Future<Map<String, dynamic>> parseConfig(File configFile) async {
    final fileAsString = await configFile.readAsString();
    final jsonConfig = JSON.decode(fileAsString) as Map<String, dynamic>;

    return jsonConfig;
  }

  Future<Map<String, dynamic>> parseAccounts(File accountsFile) async {
    final fileAsString = await accountsFile.readAsString();
    final accountsJson = JSON.decode(fileAsString);

    return accountsJson;
  }

  Future<Map<AccountSettings, Map<String, dynamic>>> generateConfigs() async {
    final parsedConfig = await parseConfig(sampleConfig);
    final jsonAccountsFile = await parseAccounts(accountsFile);

    final globalSettings = new GlobalSettings.fromMap(
        jsonAccountsFile['global'] as Map<String, dynamic>);

    final accountsJson =
        jsonAccountsFile['accounts'] as List<Map<String, dynamic>>;

    final result = <AccountSettings, Map<String, dynamic>>{};

    for (final accountJson in accountsJson) {
      final account = new AccountSettings.fromMap(accountJson);

      if (!account.enabled) {
        continue;
      }

      final withGlobalSettings =
          applyGlobalSettings(parsedConfig, globalSettings);

      final withAccountSettings =
          applyAccountSettings(withGlobalSettings, account);

      result[account] = withAccountSettings;
    }

    return result;
  }

  Future<Null> writeConfigs(
      Map<AccountSettings, Map<String, dynamic>> accounts) async {
    accounts.forEach((AccountSettings account, Map config) async {
      final toWrite =
          new File('${outputDirectory.path}/${account.filename}.json');
      await toWrite.writeAsString(encoder.convert(config));
    });
  }
}

Map<String, dynamic> getTaskConfig(
    String taskName, Map<String, dynamic> fromConfig) {
  var tasks = fromConfig['tasks'] as List<Map>;
  var matchingTask = (tasks).singleWhere((Map m) => m['type'] == taskName)
      as Map<String, dynamic>;

  return matchingTask['config'] as Map<String, dynamic>;
}
