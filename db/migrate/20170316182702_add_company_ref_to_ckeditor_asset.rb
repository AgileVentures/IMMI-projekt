class AddCompanyRefToCkeditorAsset < ActiveRecord::Migration[5.0]
  def change
    add_reference :ckeditor_assets, :company, foreign_key: true
  end
end
