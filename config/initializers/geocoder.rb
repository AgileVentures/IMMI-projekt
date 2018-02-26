Geocoder.configure(
    # Geocoding options
     timeout: 9,                  # geocoding service timeout (secs)
    # lookup: :google,            # name of geocoding service (symbol)

    language: :sv,                # ISO-639 language code

    # use_https: false,           # use HTTPS for lookup requests? (if supported)
    # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
    # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)

    # API key for geocoding service
    api_key: ENV['SHF_GOOGLE_MAP_API'],

    google_maps_js_api: "https://maps.googleapis.com/maps/api/js",

    # cache: nil,                 # cache object (must respond to #[], #[]=, and #keys)
    # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

    # Exceptions that should not be rescued by default
    # (if you want to implement custom error handling);
    # supports SocketError and Timeout::Error
    # always_raise: [],


    # Calculation options
    units: :km,                 # :km for kilometers or :mi for miles

    # distances: :linear          # :spherical or :linear
)

Geocoder.configure(always_raise: :all) unless Rails.env.production?
