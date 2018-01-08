class AddDinkursCompanyKeyToCompany < ActiveRecord::Migration[5.1]

  def change

    reversible do |direction|

      direction.up do
        add_column :companies, :dinkurs_key, :string
      end

      direction.down do
        remove_column :companies, :dinkurs_key
      end

    end

  end

end
