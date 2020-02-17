describe Animes::Filters::Policy do
  let(:params) do
    {
      achievement: achievement,
      censored: censored,
      franchise: franchise,
      genre: genre,
      ids: ids,
      kind: kind,
      mylist: mylist,
      publisher: publisher,
      rating: rating,
      studio: studio
    }
  end
  let(:achievement) { nil }
  let(:censored) { nil }
  let(:franchise) { nil }
  let(:genre) { nil }
  let(:ids) { nil }
  let(:kind) { nil }
  let(:mylist) { nil }
  let(:publisher) { nil }
  let(:rating) { nil }
  let(:studio) { nil }

  let(:no_hentai) { Animes::Filters::Policy.exclude_hentai? params }
  let(:no_music) { Animes::Filters::Policy.exclude_music? params }

  describe 'no params' do
    it { expect(no_hentai).to eq true }
    it { expect(no_music).to eq true }
  end

  describe 'achievement' do
    let(:achievement) { any_args }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end

  describe 'censored' do
    context 'true' do
      let(:censored) { [true, 'true', 1, '1'].sample }

      it { expect(no_hentai).to eq true }
      it { expect(no_music).to eq true }
    end

    context 'false' do
      let(:censored) { [false, 'false', 0, '0'].sample }

      it { expect(no_hentai).to eq false }
      it { expect(no_music).to eq false }
    end
  end

  describe 'franchise' do
    let(:franchise) { any_args }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end

  describe 'kind' do
    context 'music' do
      let(:kind) do
        [
          Types::Anime::Kind[:music],
          'music',
          'tv,music'
        ].sample
      end

      it { expect(no_hentai).to eq true }
      it { expect(no_music).to eq false }
    end

    context 'not music' do
      let(:kind) do
        [
          nil,
          'tv',
          '!music',
          'tv,!music'
        ].sample
      end

      it { expect(no_hentai).to eq true }
      it { expect(no_music).to eq true }
    end
  end

  describe 'ids' do
    let(:ids) { any_args }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end

  describe 'mylist' do
    let(:mylist) { any_args }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end

  describe 'publisher' do
    let(:publisher) { any_args }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end

  describe 'rating' do
    context 'rx || r_plus' do
      let(:rating) do
        [
          Anime::ADULT_RATING,
          Anime::SUB_ADULT_RATING,
          Anime::ADULT_RATING.to_s,
          "#{Anime::ADULT_RATING},#{Anime::SUB_ADULT_RATING}",
          "#{Anime::ADULT_RATING},!#{Anime::SUB_ADULT_RATING}",
          "!#{Anime::ADULT_RATING},#{Anime::SUB_ADULT_RATING}",
          "#{Types::Anime::Rating[:g]},#{Anime::ADULT_RATING},",
          "#{Anime::ADULT_RATING},#{Types::Anime::Rating[:g]}"
        ].sample
      end

      it { expect(no_hentai).to eq false }
      it { expect(no_music).to eq true }
    end

    context 'other' do
      let(:rating) do
        [
          "!#{Anime::SUB_ADULT_RATING}",
          "#{Types::Anime::Rating[:g]},!#{Anime::ADULT_RATING}",
          "!#{Anime::ADULT_RATING},#{Types::Anime::Rating[:g]}",
          Types::Anime::Rating[:g],
          Types::Anime::Rating[:g].to_s
        ].sample
      end

      it { expect(no_hentai).to eq true }
      # it { expect(no_music).to eq true }
    end
  end

  describe 'studio' do
    let(:studio) { any_args }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end
end