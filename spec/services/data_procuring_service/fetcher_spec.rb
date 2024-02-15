# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataProcuringService::Fetcher do
  describe '.fetch_normalized' do
    let(:data) do
      {
        acme: [{ "Id": 'f8c9', "DestinationId": 1122, "Name": 'Hilton Shinjuku Tokyo', "Latitude": '', "Longitude": '', "Address": '160-0023, SHINJUKU-KU, 6-6-2 NISHI-SHINJUKU, JAPAN', "City": 'Tokyo',
                 "Country": 'JP', "PostalCode": '160-0023', "Description": "Hilton Tokyo is located in Shinjuku, the heart of Tokyo's business, shopping and entertainment district, and is an ideal place to experience modern Japan. A complimentary shuttle operates between the hotel and Shinjuku station and the Tokyo Metro subway is connected to the hotel. Relax in one of the modern Japanese-style rooms and admire stunning city views. The hotel offers WiFi and internet access throughout all rooms and public space.", "Facilities": ['Pool', 'WiFi ', 'BusinessCenter', 'DryCleaning', ' Breakfast', 'Bar', 'BathTub'] }].map(&:with_indifferent_access)
      }
    end

    subject(:service) { described_class }

    before do
      allow(Rails.cache).to receive(:fetch).and_return(data)
    end

    it 'fetches data from all suppliers and normalizes it' do
      expect(DataProcessingService::Normalizer).to receive(:new).exactly(1).and_call_original
      expect(service.fetch_normalized).to match_array(
        [[{ id: 'f8c9',
            destination_id: 1122,
            name: 'Hilton Shinjuku Tokyo',
            location: { address: '160-0023, SHINJUKU-KU, 6-6-2 NISHI-SHINJUKU, JAPAN', city: 'Tokyo', country: 'JP' },
            description: "Hilton Tokyo is located in Shinjuku, the heart of Tokyo's business, shopping and entertainment district, and is an ideal place to experience modern Japan. A complimentary shuttle operates between the hotel and Shinjuku station and the Tokyo Metro subway is connected to the hotel. Relax in one of the modern Japanese-style rooms and admire stunning city views. The hotel offers WiFi and internet access throughout all rooms and public space.",
            amenities: { general: ['bar', 'breakfast', 'business center', 'dry cleaning', 'indoor pool', 'wifi'], room: ['bathtub'] } }]]
      )
    end
  end
end
