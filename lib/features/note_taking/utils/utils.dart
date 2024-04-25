class Utils {
  // ? see more at https://www.ascii-code.com/characters/control-characters
  static final List<String> _controlCharacters = [
    String.fromCharCodes([00]),
    String.fromCharCodes([01]),
    String.fromCharCodes([02]),
    String.fromCharCodes([03]),
    String.fromCharCodes([04]),
    String.fromCharCodes([05]),
    String.fromCharCodes([06]),
    String.fromCharCodes([07]),
    String.fromCharCodes([08]),
    String.fromCharCodes([09]),
    String.fromCharCodes([10]),
    String.fromCharCodes([11]),
    String.fromCharCodes([12]),
    String.fromCharCodes([13]),
    String.fromCharCodes([14]),
    String.fromCharCodes([15]),
    String.fromCharCodes([16]),
    String.fromCharCodes([17]),
    String.fromCharCodes([18]),
    String.fromCharCodes([19]),
    String.fromCharCodes([20]),
    String.fromCharCodes([21]),
    String.fromCharCodes([22]),
    String.fromCharCodes([23]),
    String.fromCharCodes([24]),
    String.fromCharCodes([25]),
    String.fromCharCodes([26]),
    String.fromCharCodes([27]),
    String.fromCharCodes([28]),
    String.fromCharCodes([29]),
    String.fromCharCodes([30]),
    String.fromCharCodes([31]),
  ];

  static String removeControlCharacters(String text) {
    // ? remove control characters to be able to decode the string with jsonDecode
    for (final String char in _controlCharacters) {
      // keep new line characters
      if (char == String.fromCharCodes([10])) {
        text = text.replaceAll(char, r'\n');
        continue;
      }

      text = text.replaceAll(char, '');
    }

    return text;
  }
}
