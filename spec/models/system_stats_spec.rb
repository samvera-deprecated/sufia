require 'spec_helper'

describe ::SystemStats, type: :model do
  let(:user1) { FactoryGirl.find_or_create(:user) }
  let(:morning_two_days_ago) { 2.days.ago.to_date.to_datetime.to_s }
  let(:yesterday) { 1.days.ago.to_datetime.to_s }
  let(:this_morning) { 0.days.ago.to_date.to_datetime.to_s }

  let(:stats) { described_class.new(depositor_count, user_stats[:start_date], user_stats[:end_date]) }

  describe "#top_depositors" do
    let(:user_stats) { {} }

    context "when requested count is withing bounds" do
      let!(:user2) { FactoryGirl.find_or_create(:archivist) }
      let(:depositor_count) { 15 }

      # I am specifically creating objects in this test
      # I am doing this for one test to make sure that the full loop works
      before do
        GenericFile.new(id: "abc123") do |gf|
          gf.apply_depositor_metadata(user1)
          gf.update_index
        end
        GenericFile.new(id: "def123") do |gf|
          gf.apply_depositor_metadata(user2)
          gf.update_index
        end
        GenericFile.new(id: "zzz123") do |gf|
          gf.create_date = [2.days.ago]
          gf.apply_depositor_metadata(user1)
          gf.update_index
        end
        Collection.new(id: "ccc123") do |c|
          c.apply_depositor_metadata(user1)
          c.update_index
        end
      end

      it "queries for the data" do
        expect(stats.top_depositors).to include(display_name(user1) => 3, display_name(user2) => 1)
      end
    end

    context "when requested count is too small" do
      let(:depositor_count) { 3 }
      let(:actual_count) { 5 }
      it "queries for 5 items" do
        expect(stats).to receive(:open).with("http://127.0.0.1:8983/solr/test/terms?terms.fl=depositor_tesim&terms.sort=count&terms.limit=#{actual_count}&wt=json&omitHeader=true").and_return(StringIO.new('{"terms":{"depositor_tesim":["example.com",4,"user2",3,"archivist1",1]}}'))
        stats.top_depositors
      end
    end

    context "when requested count is too big" do
      let(:depositor_count) { 99 }
      let(:actual_count) { 20 }
      it "queries for 20 items" do
        expect(stats).to receive(:open).with("http://127.0.0.1:8983/solr/test/terms?terms.fl=depositor_tesim&terms.sort=count&terms.limit=#{actual_count}&wt=json&omitHeader=true").and_return(StringIO.new('{"terms":{"depositor_tesim":["example.com",4,"user2",3,"archivist1",1]}}'))
        stats.top_depositors
      end
    end
  end

  def display_name(user)
    user.user_key.split('@')[0]
  end

  describe "#document_by_permission" do
    let(:user_stats) { {} }
    let(:depositor_count) { nil }

    before do
      FactoryGirl.build(:public_pdf, depositor: user1, id: "pdf1223").update_index
      FactoryGirl.build(:public_wav, depositor: user1, id: "wav1223").update_index
      FactoryGirl.build(:public_mp3, depositor: user1, id: "mp31223", create_date: [2.days.ago]).update_index
      FactoryGirl.build(:registered_file, depositor: user1, id: "reg1223").update_index
      FactoryGirl.build(:generic_file, depositor: user1, id: "private1223").update_index
      Collection.new(id: "ccc123") do |c|
        c.apply_depositor_metadata(user1)
        c.update_index
      end
    end
    it "get all documents by permissions" do
      expect(stats.document_by_permission).to include(public: 3, private: 1, registered: 1, total: 5)
    end

    context "when passing a start date" do
      let(:user_stats) { { start_date: yesterday } }
      it "get documents after date by permissions" do
        expect(stats.document_by_permission).to include(public: 2, private: 1, registered: 1, total: 4)
      end

      context "when passing an end date" do
        let(:user_stats) { { start_date: morning_two_days_ago, end_date: yesterday } }
        it "get documents between dates by permissions" do
          expect(stats.document_by_permission).to include(public: 1, private: 0, registered: 0, total: 1)
        end
      end
    end
  end

  describe "#top_formats" do
    let(:user_stats) { {} }
    let(:depositor_count) { nil }

    before do
      FactoryGirl.build(:public_pdf, depositor: user1, id: "pdf1111").update_index
      FactoryGirl.build(:public_wav, depositor: user1, id: "wav1111").update_index
      FactoryGirl.build(:public_mp3, depositor: user1, id: "mp31111", create_date: [2.days.ago]).update_index
      FactoryGirl.build(:registered_file, depositor: user1, id: "word1111", mime_type: "application/vnd.ms-word.document").update_index
    end

    subject { stats.top_formats }

    it { is_expected.to include("mpeg" => 1, "pdf" => 1, "wav" => 1, "vnd.ms-word.document" => 1) }

    context "when more than 5 formats available" do
      before do
        FactoryGirl.build(:public_pdf, depositor: user1, id: "pdf2222").update_index
        FactoryGirl.build(:public_wav, depositor: user1, id: "wav2222").update_index
        FactoryGirl.build(:public_mp3, depositor: user1, id: "mp32222", create_date: [2.days.ago]).update_index
        FactoryGirl.build(:registered_file, depositor: user1, id: "reg2222", mime_type: "application/vnd.ms-word.document").update_index
        FactoryGirl.build(:generic_file, depositor: user1, id: "png1111", mime_type: "image/png").update_index
        FactoryGirl.build(:generic_file, depositor: user1, id: "png2222", mime_type: "image/png").update_index
        FactoryGirl.build(:generic_file, depositor: user1, id: "jpeg2222", mime_type: "image/jpeg").update_index
      end

      it do
        is_expected.to include("mpeg" => 2, "pdf" => 2, "wav" => 2, "vnd.ms-word.document" => 2, "png" => 2)
        is_expected.not_to include("jpeg" => 1)
      end
    end
  end

  describe "#recent_users" do
    let!(:user2) { FactoryGirl.find_or_create(:archivist) }

    let(:one_day_ago_date) { 1.days.ago.to_datetime }
    let(:two_days_ago_date) { 2.days.ago.to_datetime.end_of_day }
    let(:one_day_ago) { one_day_ago_date.strftime("%Y-%m-%d") }
    let(:two_days_ago) { two_days_ago_date.strftime("%Y-%m-%d") }
    let(:depositor_count) { nil }

    subject { stats.recent_users }

    context "without dates" do
      let(:user_stats) { {} }
      let(:mock_order) { double }
      let(:mock_limit) { double }
      it "defaults to latest 5 users" do
        expect(mock_order).to receive(:limit).with(5).and_return(mock_limit)
        expect(User).to receive(:order).with('created_at DESC').and_return(mock_order)
        is_expected.to eq mock_limit
      end
    end

    context "with start date" do
      let(:user_stats) { { start_date: one_day_ago } }

      it "allows queries against user_stats without an end date " do
        expect(User).to receive(:recent_users).with(one_day_ago_date, nil).and_return([user2])
        is_expected.to eq([user2])
      end
    end
    context "with start date and end date" do
      let(:user_stats) { { start_date: two_days_ago, end_date: one_day_ago } }
      it "queries" do
        expect(User).to receive(:recent_users).with(two_days_ago_date, one_day_ago_date).and_return([user2])
        is_expected.to eq([user2])
      end
    end
  end

  describe "#users_count" do
    let(:user_stats) { {} }
    let(:depositor_count) { nil }
    let!(:user1) { FactoryGirl.find_or_create(:user) }
    let!(:user2) { FactoryGirl.find_or_create(:archivist) }

    subject { stats.users_count }

    it { is_expected.to eq 2 }
  end
end
