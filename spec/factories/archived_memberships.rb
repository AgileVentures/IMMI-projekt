FactoryBot.define do
  factory :archived_membership do
    belonged_to_first_name { 'FormerUser-FirstName' }
    belonged_to_last_name { 'FormerUser-LastName' }
    belonged_to_email { 'former_user@example.com' }
    member_number { "1234 some number" }
    first_day { "2021-02-16" }
    last_day { "2022-02-17" }
    notes { "This is a note about this particular membership that the admin might haved entered." }
  end
end
