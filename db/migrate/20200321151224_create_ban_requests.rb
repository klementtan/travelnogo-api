class CreateBanRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :ban_requests do |t|
      t.string :ban_type
      t.string :ban_description
      t.string :ban_url
      t.belongs_to :banner
      t.belongs_to :bannee
      t.belongs_to :contributor

      t.timestamps
    end
  end
end
