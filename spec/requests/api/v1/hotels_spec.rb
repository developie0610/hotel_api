# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Hotels API', type: :request do
  let(:data_paperflies) do
    {
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
        "All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room."
      ]
    }
  end
  let(:data_patagonia) do
    {
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
    }
  end
  let(:data_acme) do
    {
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
    }
  end

  before do
    allow(DataProcuringService::Fetcher).to receive(:fetch_raw).and_return({
                                                                             acme: [data_acme],
                                                                             patagonia: [data_patagonia],
                                                                             paperflies: [data_paperflies]
                                                                           })
  end

  path '/api/v1/hotels' do
    get 'Retrieves hotels by destination ID' do
      tags 'Hotels API'
      produces 'application/json'

      parameter name: :destination_id, in: :query, type: :integer, description: 'Destination ID', required: false
      parameter name: :'hotel_ids[]', in: :query, type: :array, items: { type: :string }, description: 'Hotel IDs', required: false

      response '200', 'Hotels found by destination ID' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   destination_id: { type: :integer },
                   name: { type: :string },
                   location: {
                     type: :object,
                     properties: {
                       address: { type: :string },
                       city: { type: :string },
                       country: { type: :string },
                       lat: { type: :number },
                       lng: { type: :number }
                     }
                   },
                   description: { type: :string },
                   amenities: {
                     type: :object,
                     properties: {
                       general: { type: :array, items: { type: :string } },
                       room: { type: :array, items: { type: :string } }
                     }
                   },
                   images: {
                     type: :object,
                     properties: {
                       rooms: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             link: { type: :string },
                             description: { type: :string }
                           }
                         }
                       },
                       site: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             link: { type: :string },
                             description: { type: :string }
                           }
                         }
                       }
                     }
                   },
                   booking_conditions: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }

        let(:destination_id) { 5432 }

        run_test!
      end

      response '200', 'Hotels found by hotel IDs' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   destination_id: { type: :integer },
                   name: { type: :string },
                   location: {
                     type: :object,
                     properties: {
                       address: { type: :string },
                       city: { type: :string },
                       country: { type: :string },
                       lat: { type: :number },
                       lng: { type: :number }
                     }
                   },
                   description: { type: :string },
                   amenities: {
                     type: :object,
                     properties: {
                       general: { type: :array, items: { type: :string } },
                       room: { type: :array, items: { type: :string } }
                     }
                   },
                   images: {
                     type: :object,
                     properties: {
                       rooms: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             link: { type: :string },
                             description: { type: :string }
                           }
                         }
                       },
                       site: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             link: { type: :string },
                             description: { type: :string }
                           }
                         }
                       }
                     }
                   },
                   booking_conditions: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }

        let(:'hotel_ids[]') { %w[SjyX iJhz] }

        run_test!
      end

      response '500', 'internal server error' do
        let(:error_message) { 'Grab your technical support!' }

        before do
          allow(DataDeliveryService::InformationAggregator).to receive(:new).and_raise(StandardError.new(error_message))
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq(error_message)
        end
      end
    end

    get 'Retrieves hotels by hotel IDs' do
      tags 'Hotels'
      produces 'application/json'

      parameter name: :destination_id, in: :query, type: :integer, description: 'Destination ID', required: false
      parameter name: :'hotel_ids[]', in: :query, type: :array, items: { type: :string }, description: 'Hotel IDs', required: false

      response '200', 'Hotels found by hotel IDs' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   destination_id: { type: :integer },
                   name: { type: :string },
                   location: {
                     type: :object,
                     properties: {
                       address: { type: :string },
                       city: { type: :string },
                       country: { type: :string },
                       lat: { type: :number },
                       lng: { type: :number }
                     }
                   },
                   description: { type: :string },
                   amenities: {
                     type: :object,
                     properties: {
                       general: { type: :array, items: { type: :string } },
                       room: { type: :array, items: { type: :string } }
                     }
                   },
                   images: {
                     type: :object,
                     properties: {
                       rooms: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             link: { type: :string },
                             description: { type: :string }
                           }
                         }
                       },
                       site: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             link: { type: :string },
                             description: { type: :string }
                           }
                         }
                       }
                     }
                   },
                   booking_conditions: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }

        let(:'hotel_ids[]') { %w[SjyX iJhz] }

        run_test!
      end

      response '500', 'internal server error' do
        let(:error_message) { 'Grab your technical support!' }

        before do
          allow(DataDeliveryService::InformationAggregator).to receive(:new).and_raise(StandardError.new(error_message))
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq(error_message)
        end
      end
    end
  end
end
