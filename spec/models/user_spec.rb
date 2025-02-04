require "rails_helper"

RSpec.describe User, type: :model do
  describe "passing validations" do
  subject { create(:user) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_uniqueness_of(:email).ignoring_case_sensitivity  }
  end
  describe "failing validations" do
    it "fails if email is not present" do
      user = User.new(email: nil, password: "password"       )
                      expect(user).to_ be_valid
    end
  end
end
