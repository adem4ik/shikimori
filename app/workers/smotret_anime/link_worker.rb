class SmotretAnime::LinkWorker
  include Sidekiq::Worker
  sidekiq_options queue: :anime365_parsers

  API_URL = 'https://smotretanime.ru/api/series/?myAnimeListId=%<mal_id>i&fields=id,title,links'
  SMOTRET_ANIME_URL = 'https://smotretanime.ru/catalog/%<smotret_anime_id>i'

  GIVE_UP_INTERVAL = 1.month

  def perform anime_id
    anime = Anime.find_by id: anime_id
    return unless anime&.mal_id
    return if disabled? anime

    data = fetch format(API_URL, mal_id: anime.mal_id)

    if data
      cleanup anime
      process anime, data

    elsif give_up? anime
      give_up anime
    end
  end

private

  def process anime, data
    create_link anime,
      kind: Types::ExternalLink::Kind[:smotret_anime],
      source: Types::ExternalLink::Kind[:smotret_anime],
      url: format(SMOTRET_ANIME_URL, smotret_anime_id: data[:id])

    valuable_links(data[:links]).each do |link|
      next if present? anime, link[:url]

      create_link anime,
        kind: link[:kind],
        url: link[:url],
        source: Types::ExternalLink::Source[:smotret_anime]
    end
  end

  def cleanup anime
    anime
      .all_external_links
      .where(source: Types::ExternalLink::Source[:smotret_anime])
      .delete_all

    anime.all_external_links.reset # clear association cache
  end

  def give_up? anime
    (anime.ongoing? || anime.released?) &&
      anime.aired_on && anime.aired_on < GIVE_UP_INTERVAL.ago
  end

  def give_up anime
    create_link anime,
      kind: Types::ExternalLink::Kind[:smotret_anime],
      source: Types::ExternalLink::Kind[:smotret_anime],
      url: format(SMOTRET_ANIME_URL, smotret_anime_id: Animes::SmotretAnimeId::NO_ID)
  end

  def valuable_links links
    links.map do |link|
      {
        kind: Types::ExternalLink::Kind[
          link[:title].strip.downcase.underscore.tr(' ', '_').to_sym
        ],
        url: link[:url]
      }
    rescue Dry::Types::ConstraintError
    end
    .compact
    .reject { |link| link[:kind] == Types::ExternalLink::Kind[:myanimelist] }
  end

  def create_link anime, attributes
    anime.all_external_links.create! attributes.merge(imported_at: Time.zone.now)
  end

  def disabled? anime
    anime.all_external_links.any?(&:kind_smotret_anime?) &&
      !Animes::SmotretAnimeId.call(anime)
  end

  def present? anime, url
    anime.all_external_links.any? do |external_link|
      external_link.url == url
    end
  end

  def fetch url
    JSON.parse(
      OpenURI.open_uri(url, 'User-Agent' => 'shikimori').read,
      symbolize_names: true
    ).dig(:data, 0)
  end
end
