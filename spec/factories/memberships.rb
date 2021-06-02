FactoryBot.define do
  factory :membership do
    user
    member_number { "1234 some number" }
    first_day { "2021-02-16" }
    last_day { "2022-02-17" }
    notes { "This is a note about this particular membership that the admin might enter." }
  end
end
