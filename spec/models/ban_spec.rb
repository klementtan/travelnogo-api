require 'rails_helper'

# Test suite for the Todo model
RSpec.describe Ban, type: :model do
  it { should belong_to(:banner) }
  it { should belong_to(:bannee) }
end
