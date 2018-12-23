FactoryBot.define do

  factory :condition do
    class_name { 'MyString' }
    timing { :on }
    config { {} }
  end


  trait :after do
    timing { :after }
  end

  trait :before do
    timing { :before }
  end

  trait :on  do
    timing { :on }
  end

  trait :every_day  do
    timing { :every_day }
  end

end
