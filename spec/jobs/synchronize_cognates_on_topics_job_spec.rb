require "rails_helper"

RSpec.describe SynchronizeCognatesOnTopicsJob, type: :job do
  let(:english) { create(:language, name: "english") }
  let(:spanish) { create(:language, name: "spanish") }
  let(:english_topic_1) { create(:topic, language: english) }
  let(:english_topic_2) { create(:topic, language: english) }
  let(:spanish_topic_1) { create(:topic, language: spanish) }
  let!(:tag) { create(:tag, name: "tag") }
  let!(:english_cognate) { create(:tag, name: "english cognate") }
  let!(:english_reverse_cognate) { create(:tag, name: "english reverse cognate") }
  let!(:spanish_cognate) { create(:tag, name: "spanish cognate") }
  let!(:spanish_reverse_cognate) { create(:tag, name: "spanish reverse cognate") }

  before do
    spanish_topic_1.tag_list.add([ "spanish cognate", "spanish reverse cognate" ])
    spanish_topic_1.save
    english_topic_2.tag_list.add([ "english cognate", "english reverse cognate" ])
    english_topic_2.save
  end

  context "when adding cognates to a tag" do
    before do
      english_topic_1.tag_list.add([ "tag" ])
      english_topic_1.save

      create(:tag_cognate, tag: tag, cognate: english_cognate)
      create(:tag_cognate, tag: english_reverse_cognate, cognate: tag)
      create(:tag_cognate, tag: english_reverse_cognate, cognate: english_cognate)
      create(:tag_cognate, tag: tag, cognate: spanish_cognate)
      create(:tag_cognate, tag: spanish_reverse_cognate, cognate: tag)
      create(:tag_cognate, tag: spanish_reverse_cognate, cognate: spanish_cognate)
    end

    it "adds new cognates to topics tagged with the original tag" do
      SynchronizeCognatesOnTopicsJob.perform_now(tag)
      expect(Topic.find_by(id: english_topic_1.id).tag_list)
        .to match_array([ "tag", "english cognate", "english reverse cognate", "spanish cognate", "spanish reverse cognate" ])
    end
  end
end
