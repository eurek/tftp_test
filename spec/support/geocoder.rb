RSpec.configure do |config|
  Geocoder.configure(lookup: :test)

  Geocoder::Lookup::Test.add_stub(
    "Lyon", [
      {
        "coordinates" => [45.7484600, 4.8467100],
        "address" => "Lyon, Rhône-Alpes, France",
        "state" => "Rhône-Alpes",
        "country" => "France",
        "country_code" => "FR"
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "10 rue Dumenge, Lyon", [
      {
        "coordinates" => [45.7766643, 4.83437],
        "address" => "10, Rue Dumenge, 4th Arrondissement, Lyon, Auvergne-Rhône-Alpes, 69004, France",
        "state" => "Rhône-Alpes",
        "country" => "France",
        "country_code" => "FR"
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "Paris", [
      {
        "coordinates" => [48.8534100, 2.3488000],
        "address" => "Paris, Ile-de-France, France",
        "state" => "Ile-de-France",
        "country" => "France",
        "country_code" => "FR"
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "Paris, France", [
      {
        "coordinates" => [48.8534100, 2.3488000],
        "address" => "Paris, Ile-de-France, France",
        "state" => "Ile-de-France",
        "country" => "France",
        "country_code" => "FR"
      }
    ]
  )

  Geocoder::Lookup::Test.set_default_stub([])
end
