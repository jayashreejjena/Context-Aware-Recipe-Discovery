class LocationCuisineContext {
  const LocationCuisineContext({
    required this.country,
    required this.cuisineArea,
    this.countryCode,
  });

  final String country;
  final String? countryCode;
  final String cuisineArea;
}
