class AddResolvedToScraperBanRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :scraper_ban_requests, :status, :string
  end
end
