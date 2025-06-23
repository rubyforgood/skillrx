# == Schema Information
#
# Table name: topics
#
#  id              :bigint           not null, primary key
#  description     :text
#  documents_count :integer          default(0), not null
#  published_at    :datetime         not null
#  state           :integer          default("active"), not null
#  title           :string           not null
#  uid             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  language_id     :bigint
#  old_id          :integer
#  provider_id     :bigint
#
# Indexes
#
#  index_topics_on_language_id   (language_id)
#  index_topics_on_old_id        (old_id) UNIQUE
#  index_topics_on_provider_id   (provider_id)
#  index_topics_on_published_at  (published_at)
#
require "rails_helper"

RSpec.describe Topic, type: :model do
  subject { create(:topic) }

  context "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:language_id) }
    it { should validate_presence_of(:provider_id) }
  end

  context "associations" do
    it { should have_many_attached(:documents) }
    it { is_expected.to validate_content_type_of(:documents).allowing("image/png", "image/jpeg", "image/svg+xml", "image/webp", "image/avif", "image/gif", "video/mp4") }
    it { is_expected.to validate_size_of(:documents).less_than(200.megabytes) }
  end

  context "tagging" do
    it_behaves_like "taggable"
  end

  context "documents_count" do
    it "changes the documents_count counter when adding files" do
      expect { subject.documents.attach(io: StringIO.new("test"), filename: "test.pdf", content_type: "application/pdf") }
        .to change { subject.reload.documents_count }
        .from(0)
        .to(1)
    end

    context "Topic with existing documents" do
      before do
        subject.documents.attach(
          io: File.open(Rails.root.join("test/fixtures/images/logo_ruby_for_good.png")),
          filename: "logo_ruby_for_good.png",
          content_type: "image/png"
        )
        subject.documents.attach(
          io: File.open(Rails.root.join("test/fixtures/images/skillrx_sidebar.png")),
          filename: "skillrx_sidebar.png",
          content_type: "image/png"
        )
      end

      it "changes the documents_count counter when removing files" do
        expect { subject.documents.first.destroy }
          .to change { subject.reload.documents_count }
          .from(2)
          .to(1)
      end
    end
  end
end
