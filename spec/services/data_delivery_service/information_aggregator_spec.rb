# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataDeliveryService::InformationAggregator do
  let(:data_paperflies) do
    [{
      "hotel_id": 'iJhz',
      "destination_id": 5432,
      "hotel_name": 'Beach Villas Singapore',
      "location": {
        "address": '8 Sentosa Gateway, Beach Villas, 098269',
        "country": 'Singapore'
      },
      "details": 'Surrounded by tropical gardens',
      "amenities": {
        "general": [
          'outdoor pool',
          'indoor pool',
          'business center',
          'childcare'
        ],
        "room": [
          'tv',
          'coffee machine',
          'kettle',
          'hair dryer',
          'iron'
        ]
      },
      "images": {
        "rooms": [
          {
            "link": 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg',
            "caption": 'Double room'
          }
        ],
        "site": [
          {
            "link": 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg',
            "caption": 'Front'
          }
        ]
      },
      "booking_conditions": [
        'All children are welcome.'
      ]
    }.with_indifferent_access]
  end
  let(:data_patagonia) do
    [{
      "id": 'iJhz',
      "destination": 5432,
      "name": 'Beach Villas Singapore',
      "lat": 1.264751,
      "lng": 103.824006,
      "address": '8 Sentosa Gateway, Beach Villas, 098269',
      "info": 'Located at the western tip of Resorts World Sentosa.',
      "amenities": [
        'Aircon',
        'Tv',
        'Coffee machine',
        'Kettle',
        'Hair dryer',
        'Iron',
        'Tub'
      ],
      "images": {
        "rooms": [
          {
            "url": 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg',
            "description": 'Double room'
          },
          {
            "url": 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg',
            "description": 'Bathroom'
          }
        ],
        "amenities": [
          {
            "url": 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg',
            "description": 'RWS'
          },
          {
            "url": 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg',
            "description": 'Sentosa Gateway'
          }
        ]
      }
    }.with_indifferent_access]
  end
  let(:data_acme) do
    [{
      "Id": 'iJhz',
      "DestinationId": 5432,
      "Name": 'Beach Villas Singapore',
      "Latitude": 1.264751,
      "Longitude": 103.824006,
      "Address": ' 8 Sentosa Gateway, Beach Villas ',
      "City": 'Singapore',
      "Country": 'SG',
      "PostalCode": '098269',
      "Description": '  This 5 star hotel is located on the coastline of Singapore.',
      "Facilities": [
        'Pool',
        'BusinessCenter',
        'WiFi ',
        'DryCleaning',
        ' Breakfast'
      ]
    }.with_indifferent_access]
  end

  before do
    allow(DataProcuringService::Fetcher).to receive(:fetch_raw).and_return({
                                                                             acme: data_acme,
                                                                             patagonia: data_patagonia,
                                                                             paperflies: data_paperflies
                                                                           })
  end

  describe '#call' do
    let(:params) { {} }
    let(:datasets) { [] }
    subject(:service) { described_class.new(params, datasets) }

    context 'when hotel information are present' do
      let(:params) { { destination_id: 5432 } }

      it 'returns merged and processed data' do
        result = service.call
        expect(result).to all(be_a(Hash))
        expect(result[0]).to include(
          { id: 'iJhz',
            destination_id: 5432,
            name: 'Beach Villas Singapore',
            location: { address: '8 Sentosa Gateway, Beach Villas, 098269', city: 'Singapore', country: 'Singapore', lat: 1.264751, lng: 103.824006 },
            description: 'Surrounded by tropical gardens',
            amenities: { general: ['breakfast', 'business center', 'dry cleaning', 'indoor pool', 'wifi', 'childcare', 'outdoor pool'],
                         room: ['aircon', 'bathtub', 'coffee machine', 'hair dryer', 'iron', 'kettle', 'tv'] },
            images: { 'rooms' =>
    [{ link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg', description: 'Bathroom' },
     { link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg', description: 'Double room' },
     { link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg', description: 'Double room' }],
                      'amenities' =>
    [{ link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg', description: 'RWS' },
     { link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg', description: 'Sentosa Gateway' }],
                      'site' => [{ link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg', description: 'Front' }] },
            booking_conditions: ['All children are welcome.'] }
        )
      end
    end

    context 'when hotel information are missing' do
      let(:params) { { destination_id: 5432 } }
      let(:datasets) { [{}] }

      it 'returns an empty array' do
        result = service.call

        expect(result).to eq([])
      end
    end

    context 'when query invalid value' do
      let(:params) { { hotel_ids: ['0'] } }

      it 'returns an empty array' do
        result = service.call

        expect(result).to eq([])
      end
    end
  end
end
