class Coub::Author
  include ShallowAttributes

  attribute :permalink, String
  attribute :name, String
  attribute :avatar_template, String

  URL_TEMPLATE = 'https://coub.com/%<permalink>s'
  VERSION_TEMPALTE = '%{version}' # rubocop:disable FormatStringToken
  # medium
  # medium_2x
  # profile_pic
  # profile_pic_new
  # profile_pic_new_2x
  # tiny
  # tiny_2x
  # small
  # small_2x
  # ios_large
  # ios_small

  def url
    format URL_TEMPLATE, permalink: permalink
  end

  def avatar_url
    avatar_template.gsub(VERSION_TEMPALTE, 'medium')
  end

  def avatar_2x_url
    avatar_template.gsub(VERSION_TEMPALTE, 'medium_2x')
  end
end
