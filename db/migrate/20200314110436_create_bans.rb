class CreateBans < ActiveRecord::Migration[6.0]
  def change
    create_table :bans do |t|
      t.string :ban_type
      t.string :ban_description
      t.belongs_to :banner
      t.belongs_to :bannee

      t.timestamps
    end
  end
end
