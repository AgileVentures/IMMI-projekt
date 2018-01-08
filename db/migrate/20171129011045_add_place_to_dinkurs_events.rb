class AddPlaceToDinkursEvents < ActiveRecord::Migration[5.1]
  def change
    reversible do |direction|

      direction.up do
        add_column :dinkurs_events, :place, :string
      end

      direction.down do
        remove_column :dinkurs_events, :place
      end

    end
  end
end
