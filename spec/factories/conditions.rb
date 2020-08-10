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

  trait :day_of_week do
    timing { :day_of_week }
    config { {day_of_week: [1]} }
  end

  trait :monthly do
    timing { :on_month_day }
    config { {days: [2, 16]} }
  end

end
