import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'src/remove_crap_pokemons.dart';
import 'src/apply_remove_any_release_rule.dart';
import 'src/apply_items_filter.dart';

export 'src/apply_items_filter.dart';

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
  bool removeCrapPokemons;
  Map<String, dynamic> releaseAnyRule;
  Map<String, int> itemFilters;

  GlobalSettings.fromMap(Map<String, dynamic> json) {
    gmapKey = json['gmapkey'];
    password = json['password'];
    longerEggsFirst = json['longer_eggs_first'];
    useLuckyEgg = json['use_lucky_egg'];
    maxSteps = json['max_steps'];
    walkSpeed = json['walk'];
    locationCache = json['location_cache'];
    removeSpiral = json['remove_spiral'];
    removeCrapPokemons = json['remove_crap_pokemons'];
    releaseAnyRule = json['release_any_rule'] as Map<String, dynamic>;
    itemFilters = json['items'] as Map<String, int>;
  }
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
      Map<String, dynamic> config, GlobalSettings settings) {
    final newConfig = new Map.from(config) as Map<String, dynamic>;

    if (settings.password != null) {
      newConfig['password'] = settings.password;
    }

    newConfig['gmapkey'] = settings.gmapKey;
    newConfig['max_steps'] = settings.maxSteps;
    newConfig['walk'] = settings.walkSpeed;
    newConfig['location_cache'] = settings.locationCache;

    final tasks = newConfig['tasks'] as List<Map>;

    final incubateEggsTask =
        (tasks).singleWhere((Map m) => m['type'] == incubateTaskName);
    incubateEggsTask['config']['longer_eggs_first'] = settings.longerEggsFirst;

    final evolveAllTask =
        (tasks).singleWhere((Map m) => m['type'] == evolveAllTaskName);
    evolveAllTask['config']['use_lucky_egg'] = settings.useLuckyEgg;

    tasks.removeWhere((Map m) => m['type'] == followSpiralTaskName);

    if (settings.removeCrapPokemons) {
      removeCrapPokemons(newConfig);
    }

    if (settings.releaseAnyRule != null) {
      applyNewReleaseAnyRule(config, settings.releaseAnyRule);
    }

    if (settings.itemFilters != null) {
      applyItemFilters(config, settings.itemFilters);
    }

    return newConfig;
  }
}

Map<String, dynamic> getTaskConfig(
    String taskName, Map<String, dynamic> fromConfig) {
  var tasks = fromConfig['tasks'] as List<Map>;
  var matchingTask = (tasks).singleWhere((Map m) => m['type'] == taskName)
      as Map<String, dynamic>;

  return matchingTask['config'] as Map<String, dynamic>;
}
