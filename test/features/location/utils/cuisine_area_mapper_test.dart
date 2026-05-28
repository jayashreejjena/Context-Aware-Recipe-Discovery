import 'package:flutter_test/flutter_test.dart';
import 'package:recipediscovery/features/location/utils/cuisine_area_mapper.dart';

void main() {
  test('maps known country codes to TheMealDB cuisine areas', () {
    expect(CuisineAreaMapper.fromCountry(countryCode: 'IN'), 'Indian');
    expect(CuisineAreaMapper.fromCountry(countryCode: 'US'), 'American');
    expect(CuisineAreaMapper.fromCountry(countryCode: 'GB'), 'British');
  });

  test('falls back to country name and default cuisine', () {
    expect(CuisineAreaMapper.fromCountry(country: 'Japan'), 'Japanese');
    expect(CuisineAreaMapper.fromCountry(country: 'Unknown'), 'American');
  });
}
