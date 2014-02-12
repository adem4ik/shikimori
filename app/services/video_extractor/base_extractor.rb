class VideoExtractor::BaseExtractor
  attr_reader :url

  def initialize url
    @url = url
  end

  def fetch
    VideoData.new hosting, image_url, player_url if valid_url?

  rescue OpenURI::HTTPError => e
  rescue EmptyContent => e
  end

  def hosting
    self
      .class
      .name
      .to_underscore
      .sub(/.*::_?/, '')
      .sub(/_extractor/, '')
      .to_sym
  end

  def valid_url?
    self.class.valid_url? url
  end

  def self.valid_url? url
    url =~ self::URL_REGEX
  end
end
