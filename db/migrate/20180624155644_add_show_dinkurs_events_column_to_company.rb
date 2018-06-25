class AddShowDinkursEventsColumnToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :show_dinkurs_events, :boolean
  end
end
