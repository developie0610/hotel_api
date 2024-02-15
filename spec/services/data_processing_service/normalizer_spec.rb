# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataProcessingService::Normalizer do
  describe '#call' do
    let(:data) do
      {
        Id: 'iJhz',
        DestinationId: 5432,
        Name: 'Beach Villas Singapore',
        Latitude: 1.264751,
        Longitude: 103.824006,
        Address: '8 Sentosa Gateway, Beach Villas, 098269',
        City: 'Singapore',
        Country: 'SG',
        PostalCode: '098269',
        Description: 'This 5 star hotel is located on the coastline of Singapore.',
        Facilities: ['Pool', 'BusinessCenter', 'WiFi ', 'DryCleaning', ' Breakfast']
      }.with_indifferent_access
    end

    let(:supplier) { :acme }
    let(:expected_normalized_data) do
      {
        id: 'iJhz',
        destination_id: 5432,
        name: 'Beach Villas Singapore',
        location: {
          lat: 1.264751,
          lng: 103.824006,
          address: '8 Sentosa Gateway, Beach Villas, 098269',
          city: 'Singapore',
          country: 'SG'
        },
        description: 'This 5 star hotel is located on the coastline of Singapore.',
        amenities: {
          general: ['breakfast', 'business center', 'dry cleaning', 'indoor pool', 'wifi']
        }
      }
    end

    subject(:service) { described_class.new([data], supplier) }

    it 'normalizes the data according to the supplier data mapping' do
      expect(service.call).to eq([expected_normalized_data])
    end
  end
end
