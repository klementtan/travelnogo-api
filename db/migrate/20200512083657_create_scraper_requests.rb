class CreateScraperRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :scraper_requests do |t|
      t.date :date
      t.string :source

      t.timestamps
    end
  end
end
