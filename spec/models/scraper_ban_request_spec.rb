require 'rails_helper'

RSpec.describe ScraperBanRequest, type: :model do
  it { should belong_to(:banner) }
  it { should belong_to(:bannee) }
  it { should belong_to(:scraper_request) }
  it { should validate_presence_of(:ban_description) }
  it 'Should Initialize with default pending status' do
    scraper_ban_request = ScraperBanRequest.create
    expect(scraper_ban_request.status).to eq(
      ScraperRequestStatus::PENDING_REVIEW
    )
  end
end
