require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { should have_many(:tag_cognates) }
    it { should have_many(:cognates).through(:tag_cognates) }
    it { should have_many(:reverse_tag_cognates).class_name("TagCognate") }
    it { should have_many(:reverse_cognates).through(:reverse_tag_cognates) }
  end
end
