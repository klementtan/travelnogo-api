class AddUrlToBan < ActiveRecord::Migration[6.0]
  def change
    add_column :bans, :ban_url, :string
  end
end
