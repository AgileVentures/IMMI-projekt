FactoryBot.define do

  factory :app_configuration, class: AdminOnly::AppConfiguration do

    chair_signature do
      File.new("#{Rails.root}/spec/fixtures/app_configuration/chair_signature.png")
    end

    shf_logo do
      File.new("#{Rails.root}/spec/fixtures/app_configuration/medlem.png")
    end
  end
end
