require 'rails_helper'

RSpec.describe ScraperRequest, type: :model do
  it { should have_many(:scraper_ban_requests) }
  it { should validate_presence_of(:source) }
  it { should validate_presence_of(:date) }
end
