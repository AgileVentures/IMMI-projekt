class AddShowDinkursEventsColumnToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :show_dinkurs_events, :boolean
    Company.find_each do |company|
      company.show_dinkurs_events = !company.dinkurs_company_id.blank?
    end
  end
end
