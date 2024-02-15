# frozen_string_literal: true

module DataProcessingService
  class Merger
    SINGLE_VALUE_KEYS = %i[id destination_id name location description].freeze
    IMAGE_SORT_KEY = :description

    # Initializes the Merger with datasets.
    #
    # @param datasets [Array<Hash>] The datasets to be merged.
    def initialize(datasets)
      @datasets = Sorter.new(datasets).call
    end

    # Merges datasets and combines specific data fields.
    #
    # @return [Hash] The merged data.
    def call
      merged_data = merge_single_value_keys
      merged_data[:amenities] = combine_data(:amenities)
      merged_data[:images] = combine_images
      merged_data[:booking_conditions] = combine_data(:booking_conditions, :array)
      merged_data
    end

    private

    def merge_single_value_keys
      @datasets.reduce({}) do |merged_hash, data_hash|
        merged_hash.deep_merge(data_hash.slice(*SINGLE_VALUE_KEYS))
      end
    end

    def combine_images
      images = combine_data(:images, :hash)
      images.transform_values { |images| images.sort_by { |image| image[IMAGE_SORT_KEY] } }
    end

    def sort_images(image_collection)
      image_collection.sort_by { |image| image[IMAGE_SORT_KEY] }
    end

    def combine_data(key, data_type = :hash)
      case data_type
      when :hash
        @datasets.reduce({}) do |merged_data, data_hash|
          merged_data.merge(data_hash[key] || {}) { |_key, old_val, new_val| Array(old_val) | Array(new_val) }
        end
      when :array
        @datasets.reduce([]) { |merged_data, data_array| merged_data | Array(data_array[key]) }.sort
      end
    end
  end
end
