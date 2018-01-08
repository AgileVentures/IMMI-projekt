FactoryGirl.define do

  sequence(:dinkurs_id) { |num| "dke-#{num}" }

  factory :dinkurs_event do

    name "Event #{dinkurs_id}"
    start DateTime.parse("1 April 2017")
    key "VoofVoofVoofVoof12345"

    association :company, factory: :company

    after(:build) do | dk_event, evaluator |
      dk_event.url_id = ( evaluator.url_id ? evaluator.url_id : "https://dinkurs.se/appliance/?event_id=#{dk_event.dinkurs_id}" )
      dk_event.url_key = ( evaluator.url_key ? evaluator.url_key : "https://dinkurs.se/appliance/?event_key=#{dk_event.key}" )
    end

  end

end
