describe Elasticsearch::Query::Manga, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :mangas
    MangasIndex.purge!
  end

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit
    )
  end

  let!(:manga_1) { create :manga, name: 'test' }
  let!(:manga_2) { create :manga, name: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [manga_1.id, manga_2.id] }
end
