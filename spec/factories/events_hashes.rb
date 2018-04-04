# frozen_string_literal: true

FactoryBot.define do
  factory :events_hashes, class: Array do
    array do
      [
          {
            dinkurs_id: '26230',
            name: 'Intresselista',
            fee: 0.0,
            start_date: '2040-01-01'.to_date,
            description: nil,
            sign_up_url:
              'https://dinkurs.se/appliance/?event_key=LGbRBLplIUHsNJHF',
            company_id: 1
          },
          {
            dinkurs_id: '41988',
            name: 'stav',
            fee: 300.0,
            start_date: '2040-01-01'.to_date,
            description: 'Informationstext innan anmälningsformuläret\n\nLämna'\
                         ' denna ruta tom för att låta deltagaren komma direkt'\
                         ' till anmälningsformuläret',
            sign_up_url:
              'https://dinkurs.se/appliance/?event_key=BLQHndUsZcZHrJhR',
            company_id: 1
          }
      ]
    end
    initialize_with { array }
  end
end
