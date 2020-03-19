require 'rails_helper'

# Test suite for the Todo model
RSpec.describe Country, type: :model do
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:country_name) }
end