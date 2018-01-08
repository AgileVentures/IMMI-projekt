class AddCompanyToDinkursEvent < ActiveRecord::Migration[5.1]

  def change
    add_reference :dinkurs_events, :company, foreign_key: true
  end

end
