class AddPublishedDateToScraperBanRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :scraper_ban_requests, :published_date, :date
  end
end
