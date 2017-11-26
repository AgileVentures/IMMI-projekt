class AddDatesToPayments < ActiveRecord::Migration[5.1]
  def change

    reversible do |direction|
      direction.up do
        add_column :payments, :start_date, :date
        add_column :payments, :expire_date, :date
        add_column :payments, :notes, :text
      end

      direction.down do
        remove_columns :payments, :start_date, :expire_date, :notes
      end
    end
  end
end
