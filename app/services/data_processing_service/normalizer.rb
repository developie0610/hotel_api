# frozen_string_literal: true

module DataProcessingService
  class Normalizer
    CONFIG_PATH = 'config'
    MAPPING_PATH = 'supplier_mappings.yml'

    GENERAL_AMENITIES = ['bar', 'breakfast', 'business center', 'childcare', 'concierge', 'dry cleaning', 'indoor pool', 'outdoor pool', 'parking', 'wifi'].freeze
    ROOM_AMENITIES = ['aircon', 'bathtub', 'coffee machine', 'hair dryer', 'iron', 'kettle', 'minibar', 'tv'].freeze

    ALL_AMENITIES = (GENERAL_AMENITIES + ROOM_AMENITIES).to_h { |amen| [amen.gsub(' ', ''), amen] }.freeze
    ALL_AMENITIES_NORMALIZED = Set.new(ALL_AMENITIES.keys).freeze

    # OUTPUT data structure:
    # {
    #     "id": '',
    #     "destination_id": nil,
    #     "name": '',
    #     "location": {
    #       "lat": nil,
    #       "lng": nil,
    #       "address": '',
    #       "city": '',
    #       "country": ''
    #     },
    #     "description": '',
    #     "amenities": {
    #       "general": [],
    #       "room": []
    #     },
    #     "images": {
    #       "rooms": [],
    #       "site": [],
    #       "amenities": []
    #     },
    #     "booking_conditions": []
    #   }
    #
    # Initializes the Normalizer with dataset and supplier.
    #
    # @param dataset [Array<Hash>] The dataset to be normalized.
    # @param supplier [Symbol] The supplier key.
    def initialize(dataset, supplier)
      @dataset = dataset
      @supplier_mapping = YAML.load_file(Rails.root.join(CONFIG_PATH, MAPPING_PATH))[supplier.to_s].deep_symbolize_keys
    end

    # Normalizes the dataset based on supplier mappings.
    #
    # @return [Array<Hash>] The normalized dataset.
    def call
      return [] unless @supplier_mapping.present?

      @dataset.map { |data| normalize(@supplier_mapping, data) }
    end

    private

    def normalize(data_mapping, data)
      normalize_data = {}
      data_mapping.each do |key, value|
        if value.is_a?(Hash)
          normalize_data[key] = {}
          value.each do |sub_key, sub_value|
            sub_data = data.dig(*sub_value.split('.'))
            normalize_data[key][sub_key] = clean_data(sub_data) if sub_data.present?
          end
        else
          top_level_data = data.dig(*value.split('.'))
          normalize_data[key] = clean_data(top_level_data) if top_level_data.present?
        end
      end

      normalize_data[:amenities] = normalize_amenities(normalize_data[:amenities]) if normalize_data[:amenities]
      normalize_data[:images] = normalize_images(normalize_data[:images]) if normalize_data[:images]
      normalize_data
    end

    def clean_data(data)
      return data unless data.is_a?(String)

      data.strip.gsub(/\s+/, ' ')
    end

    def normalize_amenities(amenities)
      return {} unless amenities

      amenities = amenities.values.flatten if amenities.is_a?(Hash)
      amenities = amenities.map { |amen| amen.strip.downcase.gsub(' ', '') }

      available_amenities = amenities.map do |amen|
        next ALL_AMENITIES[amen] if ALL_AMENITIES[amen]

        ALL_AMENITIES[ALL_AMENITIES_NORMALIZED.find { |amen_norm| amen_norm.include?(amen) }]
      end

      {
        general: GENERAL_AMENITIES & available_amenities,
        room: ROOM_AMENITIES & available_amenities
      }.reject { |_k, v| v.empty? }
    end

    def normalize_images(images)
      images.transform_values do |image_collection|
        image_collection.map do |image|
          {
            link: image['link'] || image['url'],
            description: image['caption'] || image['description']
          }
        end
      end.reject { |_k, v| v.empty? } # rubocop:disable Style/MultilineBlockChain
    end
  end
end
