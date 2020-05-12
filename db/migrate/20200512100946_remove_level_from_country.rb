class RemoveLevelFromCountry < ActiveRecord::Migration[6.0]
  def change
    remove_column :countries, :level
    add_column :countries, :all_countries, :boolean
  end
end
