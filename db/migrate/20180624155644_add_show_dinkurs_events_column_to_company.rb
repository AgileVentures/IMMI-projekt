class AddShowDinkursEventsColumnToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :show_dinkurs_events, :boolean
    Company.where.not(dinkurs_company_id: [nil, '']).each do
      |c| c.update_attribute(:show_dinkurs_events, true)
    end
  end
end
