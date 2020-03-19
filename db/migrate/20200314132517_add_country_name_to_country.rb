class AddCountryNameToCountry < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :country_name, :string
  end
end
