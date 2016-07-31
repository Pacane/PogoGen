# PogoGen

## Why?
If you're using [PokemonGo-Bot](https://github.com/PokemonGoF/PokemonGo-Bot/) 
to level multiple accounts, you might have noticed that the `dev` branch
changes quite often the structure of the configuration files.

Now I've made this to update my files easily when the structure changed.

## Instructions

### The account file
You need to have an account json file like [this one](https://github.com/Pacane/PogoGen/tree/master/test/accounts.json):

Put it in `/path/to/PokemonGo-Bot/configs`. You can then fill it with each bot's information.
The "Global" section will be applied to all configurations.

__NOTE: The currently supported keys are strictly in the provided JSON above. More keys will come.__

### PogoGen
__You need to have [Google Dart](https://www.dartlang.org/) installed.__

- From the terminal run this:

`pub global activate pogogen`

- Still in the terminal, from your `PokemonGo-Bot` directory, you'll need to type:

`pogogen`

- For more options use `pogogen --help`.
- By default it'll use `configs/config.json.pokemon.example` as its template.

