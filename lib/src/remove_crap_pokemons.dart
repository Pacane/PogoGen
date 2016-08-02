import 'pokemons.dart';

void removeCrapPokemons(Map<String, dynamic> config) {
  final releaseRules = config['release'] as Map<String, dynamic>;

  crapPokemons.forEach((var pokemonName) => releaseRules.remove(pokemonName));
}
