# frozen_string_literal: true

module DataProcuringService
  class Fetcher
    BASE_URLS = {
      acme: 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme',
      patagonia: 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/patagonia',
      paperflies: 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/paperflies'
    }.freeze

    DATA_CACHE_KEY = "#{name}:fetch_raw".freeze

    class << self
      # Fetches data from the specified supplier API.
      #
      # @param supplier [Symbol] The name of the supplier.
      # @return [Hash] The data fetched from the supplier API.
      # @raise [ArgumentError] If the supplier URL is invalid.
      def fetch_data(supplier)
        url = BASE_URLS[supplier.to_sym]
        raise ArgumentError, 'Invalid supplier' unless url

        response = Net::HTTP.get_response(URI(url))
        JSON.parse(response.body)
      end

      # Fetches raw data from supplier APIs, either from cache or by making API requests.
      #
      # @param refresh [Boolean] Whether to force a refresh of the cache.
      # @return [Hash] The raw data from supplier APIs.
      def fetch_raw(refresh: false)
        refresh_cache if refresh
        cached_supplier_data
      end

      # Fetches and normalizes data from supplier APIs.
      #
      # @return [Array<Hash>] The normalized data from supplier APIs.
      def fetch_normalized
        fetch_raw.map { |supplier, data| DataProcessingService::Normalizer.new(data, supplier).call }
      end

      private

      def refresh_cache
        Rails.cache.delete(DATA_CACHE_KEY)
      end

      def cached_supplier_data
        Rails.cache.fetch(DATA_CACHE_KEY, expires_in: 1.hour) do
          supplier_data = {}
          BASE_URLS.each_key { |supplier| supplier_data[supplier] = fetch_data(supplier) }
          supplier_data
        end
      end
    end
  end
end
