class Tracks::ApproachesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution
  before_action :use_approach, only: :show
  before_action :guard_accessible!

  skip_before_action :authenticate_user!

  def index
    @videos = @exercise.community_videos.approved
    @approaches = @exercise.approaches.random
    @introduction = introduction
    @links = links
  end

  def show
    @other_approaches = SerializeApproaches.(@exercise.approaches.where.not(id: @approach.id).random)
    @num_authors = @approach.authors.count
    @num_contributors = @approach.contributors.count
    @users = CombineAuthorsAndContributors.(@approach.authors, @approach.contributors).map do |user|
      SerializeAuthorOrContributor.(user)
    end
  end

  def tooltip_locked = render_template_as_json

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
    render_404 unless @track.accessible_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def use_approach
    @approach = @exercise.approaches.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def guard_accessible!
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?
    return if @user_track.external? || @solution&.unlocked_help? || @solution&.iterated?

    redirect_to track_exercise_path(@track, @exercise)
  end

  def introduction
    # TODO: introduce model for approach introduction
    {
      html: Markdown::Parse.(@exercise.approaches_introduction),
      avatar_urls: introduction_avatar_urls,
      num_authors: @exercise.approach_introduction_authors.count,
      num_contributors: @exercise.approach_introduction_contributors.count,
      updated_at: @exercise.approaches_introduction_last_modified_at,
      links: {
        edit: @exercise.approaches_introduction_edit_url
      }
    }
  end

  def introduction_avatar_urls
    avatar_urls = proc { |users, limit| users.order("RAND()").limit(limit).select(:avatar_url).to_a.map(&:avatar_url) }

    target = 3
    urls = avatar_urls.(@exercise.approach_introduction_authors, target)
    if urls.size < 3 && @exercise.approach_introduction_contributors.exists?
      urls += avatar_urls.(@exercise.approach_introduction_contributors, target - urls.size)
    end
    urls.compact
  end

  def links
    {
      video: {
        lookup: Exercism::Routes.lookup_api_community_videos_path,
        create: Exercism::Routes.api_community_videos_path
      }
    }
  end
end