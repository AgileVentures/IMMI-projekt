class CreateConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :conditions do |t|
      t.string :class_name
      t.string :name    # 'membership_will_expire'
      t.string :timing  # 'before', 'after'
      t.text :config    # serialized hash

      t.timestamps
    end
  end
end
