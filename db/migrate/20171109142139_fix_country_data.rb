class FixCountryData < ActiveRecord::Migration[5.1]
  def change
    execute "UPDATE addresses SET country='Sverige' WHERE country!='Sverige'"
  end
end
