# Geocode information so that Geocoder can return the information needed without having to hit the API
# @see https://github.com/alexreisner/geocoder#testing-apps-that-use-geocoder


# If  you use an address in the tests, YOU MUST CREATE THE RESULT THAT GEOCODER WILL RETURN for it.
# That means you must create and entry for it in the 'stubbed_addresses' hash below.
#
# Unless you are specifically testing the results, it doesn't really matter what data it returns just as
# long as it is valid. So just copy the results (the hash) returned from one of the addresses here and
# use that for the address you are creating.
#


# address info and coordinates with just the street number changed
#  The company factory will create this address, incrementing the address number
#   so instead of hardcoding a lot of these, we just use this method
def hunforetagarevagen(address_num)
  {
      'latitude' => 56.7422437,
      'longitude' => 12.7206453,
      'address' => "Hundforetagarevägen #{address_num}, 310 40, Harplinge, Sverige",
      'city' => 'Harplinge',
      'state' => 'Hallands län',
      'postal_code' => '310 40',
      'country' => 'Sverige',
      'country_code' => 'SE'
  }
end


stubbed_addresses = {

    "Hundvägen 101, 310 40, Harplinge, Sverige" =>
        {
            'latitude' => 56.7422437,
            'longitude' => 12.7206453,
            'address' => 'Hundvägen 101, 310 40, Harplinge, Sverige',
            'city' => 'Harplinge',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Hundforetagarevägen 1, 310 40, Harplinge, Sverige" =>
        hunforetagarevagen(1),

    "Hundforetagarevägen 2, 310 40, Harplinge, Sverige" =>
        hunforetagarevagen(2),

    "Hundforetagarevägen 3, 310 40, Harplinge, Sverige" =>
        hunforetagarevagen(3),

    "Hundforetagarevägen 4, 310 40, Harplinge, Sverige" =>
        hunforetagarevagen(4),

    "Hundforetagarevägen 5, 310 40, Harplinge, Sverige" =>
        hunforetagarevagen(5),


    "Hundforetagarevägen 1, 310 40, HasRegionBorg, Sverige" =>
        {
            'latitude' => 56.7422437,
            'longitude' => 12.7206453,
            'address' => 'Hundforetagarevägen 101, 310 40, HasRegionBorg, Sverige',
            'city' => 'HasRegionBorg',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Hundforetagarevägen 1, 310 40, NoRegionBorg, Sverige" =>
        {
            'latitude' => 56.7422437,
            'longitude' => 12.7206453,
            'address' => 'Hundforetagarevägen 101, 310 40, HasRegionBorg, Sverige',
            'city' => 'HasRegionBorg',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },



    "Kvarnliden 2, 310 40, Harplinge, Sverige" =>
        {
            'latitude' => 56.7440333,
            'longitude' => 12.727637,
            'address' => 'Kvarnlide 2, 310 40, Harplinge, Sverige',
            'city' => 'Halmstad V',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Kvarnliden 10, 310 40, Harplinge, Sverige" =>
        {
            'latitude' => 56.7422433,
            'longitude' => 12.7255982,
            'address' => 'Kvarnlide 10, 310 40, Harplinge, Sverige',
            'city' => 'Halmstad V',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Hundforetagarevägen 1, 310 40, Bagarmossen, Sverige" =>
        {
            'latitude' => 56.7422437,
            'longitude' => 12.7206453,
            'address' => 'Hundforetagarevägen 1, 310 40, Bagarmossen, Sverige',
            'city' => 'Bagarmossen',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "310 40, Harplinge, Sverige" =>
        {
            'latitude' => 56.7422437,
            'longitude' => 12.7206453,
            'address' => '310 40, Harplinge, Sverige',
            'city' => 'Harplinge',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Harplinge, Sverige" =>
        {
            'latitude' => 56.7422437,
            'longitude' => 12.7206453,
            'address' => '310 40, Harplinge, Sverige',
            'city' => 'Harplinge',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Plingshult, Sverige" =>
        {
            'latitude' => 56.633333,
            'longitude' => 13.2,
            'address' => '312 92, Plingshult, Sverige',
            'city' => 'Plingshult',
            'state' => 'Hallands län',
            'postal_code' => '312 92',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Ålstensgatan 4, 123 45, Bromma, Sverige" =>
        {
            'latitude' => 59.324624,
            'longitude' => 17.9568073,
            'address' => 'Ålstensgatan 4, 167 65, Bromma, Sverige',
            'city' => 'Stockholm',
            'state' => 'Stockholms län',
            'postal_code' => '167 65',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Matarengivägen 24, 957 31, Övertorneå, Sverige" =>
        {
            'latitude' => 66.3902538999999,
            'longitude' => 23.6601303,
            'address' => 'Matarengivägen 24, 957 31, Övertorneå, Sverige',
            'city' => 'Övertorneå',
            'state' => 'Norrbottens län',
            'postal_code' => '957 31',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Matarengivägen 30, 957 31, Övertorneå, Sverige" =>
        {
            'latitude' => 66.391559,
            'longitude' => 23.6578853,
            'address' => 'Matarengivägen 30, 957 31, Övertorneå, Sverige',
            'city' => 'Övertorneå',
            'state' => 'Norrbottens län',
            'postal_code' => '957 31',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Skolvägen 12, 957 31, Övertorneå, Sverige" =>
        {
            'latitude' => 66.3881109,
            'longitude' => 23.6482681,
            'address' => 'Skolvägen 12, 957 31, Övertorneå, Sverige',
            'city' => 'Övertorneå',
            'state' => 'Norrbottens län',
            'postal_code' => '957 31',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Hundforetagarevägen 1, 310 40, Kusmark, Sverige" =>
        {
            'latitude' => 59.324624,
            'longitude' => 17.9568073,
            'address' => 'Hundforetagarevägen 1, 310 40, Kusmark, Sverige',
            'city' => 'Kusmark',
            'state' => 'Västerbotten',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },

    "Hundforetagarevägen 1, 310 40, Morjarv, Sverige" =>
        {
            'latitude' => 59.324624,
            'longitude' => 17.9568073,
            'address' => 'Hundforetagarevägen 1, 310 40, Morjarv, Sverige',
            'city' => 'Morjarv',
            'state' => 'Norrbotten',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },

    "Hundforetagarevägen 1, 310 40, , Sverige" =>
        {
            'latitude' => 60.128161,
            'longitude' => 18.643501,
            'country' => 'Sverige',
            'country_code' => 'SE'
        },


    "Sverige" =>
        {
            'latitude' => 60.12816100000001,
            'longitude' => 18.643501,
            'address' => 'Sverige',
            'city' => 'Stockholm',
            'city' => 'Harplinge',
            'state' => 'Hallands län',
            'postal_code' => '310 40',
            'country' => 'Sverige',
            'country_code' => 'SE'
        },



}


stubbed_addresses.each {|lookup, results| Geocoder::Lookup::Test.add_stub(lookup, [results])}
