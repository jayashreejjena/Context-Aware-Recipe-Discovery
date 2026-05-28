class CuisineAreaMapper {
  const CuisineAreaMapper._();

  static const _countryCodeToArea = {
    'CA': 'Canadian',
    'CN': 'Chinese',
    'EG': 'Egyptian',
    'FR': 'French',
    'GR': 'Greek',
    'IN': 'Indian',
    'IE': 'Irish',
    'IT': 'Italian',
    'JM': 'Jamaican',
    'JP': 'Japanese',
    'KE': 'Kenyan',
    'MY': 'Malaysian',
    'MX': 'Mexican',
    'MA': 'Moroccan',
    'NL': 'Dutch',
    'PL': 'Polish',
    'PT': 'Portuguese',
    'RU': 'Russian',
    'ES': 'Spanish',
    'TH': 'Thai',
    'TN': 'Tunisian',
    'TR': 'Turkish',
    'GB': 'British',
    'US': 'American',
    'VN': 'Vietnamese',
  };

  static const _countryNameToArea = {
    'canada': 'Canadian',
    'china': 'Chinese',
    'egypt': 'Egyptian',
    'france': 'French',
    'greece': 'Greek',
    'india': 'Indian',
    'ireland': 'Irish',
    'italy': 'Italian',
    'jamaica': 'Jamaican',
    'japan': 'Japanese',
    'kenya': 'Kenyan',
    'malaysia': 'Malaysian',
    'mexico': 'Mexican',
    'morocco': 'Moroccan',
    'netherlands': 'Dutch',
    'poland': 'Polish',
    'portugal': 'Portuguese',
    'russia': 'Russian',
    'spain': 'Spanish',
    'thailand': 'Thai',
    'tunisia': 'Tunisian',
    'turkey': 'Turkish',
    'united kingdom': 'British',
    'united states': 'American',
    'united states of america': 'American',
    'vietnam': 'Vietnamese',
  };

  static String fromCountry({String? countryCode, String? country}) {
    final normalizedCode = countryCode?.trim().toUpperCase();
    if (normalizedCode != null && normalizedCode.isNotEmpty) {
      final area = _countryCodeToArea[normalizedCode];
      if (area != null) {
        return area;
      }
    }

    final normalizedCountry = country?.trim().toLowerCase();
    if (normalizedCountry != null && normalizedCountry.isNotEmpty) {
      final area = _countryNameToArea[normalizedCountry];
      if (area != null) {
        return area;
      }
    }

    return 'American';
  }
}
