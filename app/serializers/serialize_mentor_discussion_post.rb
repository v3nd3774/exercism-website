class SerializeMentorDiscussionPost
  include Mandate

  initialize_with :post, :user

  def call
    {
      id: post.uuid,
      author_handle: post.author.handle,
      author_avatar_url: post.author.avatar_url,
      by_student: post.by_student?,
      content_markdown: post.content_markdown,
      content_html: post.content_html,
      updated_at: post.updated_at.iso8601,
      links: links
    }
  end

  private
  def links
    if post.author == user
      {
        update: Exercism::Routes.api_mentor_discussion_post_url(post)
      }
    else
      {}
    end
  end
end