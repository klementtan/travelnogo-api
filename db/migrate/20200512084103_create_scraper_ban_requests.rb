class CreateScraperBanRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :scraper_ban_requests do |t|
      t.belongs_to :banner
      t.belongs_to :bannee
      t.references :scraper_request, null: false, foreign_key: true
      t.text :ban_description

      t.timestamps
    end
  end
end
