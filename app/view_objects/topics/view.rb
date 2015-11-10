class Topics::View < ViewObjectBase
  vattr_initialize :topic, :is_preview, :is_mini

  delegate :id, :persisted?, :user, :created_at, :body, :comments_count, :viewed?, to: :topic
  instance_cache :comments, :urls, :action_tag

  def ignored?
    h.user_signed_in? && h.current_user.ignores?(topic.user)
  end

  def minified?
    is_mini
  end

  def container_class css = ''
    [
      css,
      ('b-topic-preview' if is_preview),
      (:mini if is_mini),
    ].compact.join ' '
  end

  def action_tag
  end

  def show_actions?
    h.user_signed_in? && !is_mini
  end

  def show_body?
    is_preview || !topic.generated? || topic.contest?
  end

  def topic_title
    if !is_preview
      topic.user.nickname
    elsif topic.topic? || topic.linked_id.nil?
      topic.title
    else
      h.localized_name topic.linked
    end
  end

  def render_body
    html_body
  end

  # картинка топика(аватарка автора)
  def poster is_2x
    if topic.linked && is_preview
      ImageUrlGenerator.instance.url(
        (topic.review? ? topic.linked.target : topic.linked), is_2x ? :x96 : :x48
      )
    else
      topic.user.avatar_url is_2x ? 80 : 48
    end
  end

  def comments
    Topics::CommentsView.new topic, is_preview
  end

  def urls
    Topics::Urls.new topic, is_preview
  end

  def faye_channel
    ["topic-#{topic.id}"].to_json
  end

  def subscribed?
    h.current_user.subscribed? topic
  end

  def author_in_header?
    true
  end

  # def author_in_footer?
    # is_preview && (topic.news? || topic.review?) &&
      # (!author_in_header? || poster(false) != user.avatar_url(48))
  # end

  def html_body
    Rails.cache.fetch body_cache_key, expires_in: 2.weeks do
      BbCodeFormatter.instance.format_comment topic_body
    end
  end

  # # надо ли свёртывать длинный контент топика?
  # def should_shorten?
    # !news? || (news? && generated?) || (news? && object.body !~ /\[wall\]/)
  # end

  # # тег топика
  # def tag
    # return nil if linked.nil? || review? || contest?

    # if linked.kind_of? Review
      # h.localized_name linked.target
    # else
      # h.localized_name linked if linked.respond_to?(:name) && linked.respond_to?(:russian)
    # end
  # end

  def html_body_truncated
    if is_preview
      h.truncate_html(html_body,
        length: 500,
        separator: ' ',
        word_boundary: /\S[\.\?\!<>]/
      ).html_safe
    else
      html_body
    end
  end

  def html_footer
  end

  # для совместимости с комментариями для рендера тултипа
  def offtopic?; false; end

private

  def body_cache_key
    [topic, topic.linked, h.russian_names_key, 'body']
  end

  def topic_body
    topic.original_text
  end
end
