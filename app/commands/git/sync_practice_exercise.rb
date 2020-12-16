module Git
  class SyncPracticeExercise < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless exercise_needs_updating?

      exercise.update!(
        slug: exercise_config[:slug],
        title: exercise_config[:name],
        deprecated: exercise_config[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid,
        prerequisites: find_concepts(exercise_config[:prerequisites])
      )
    end

    private
    attr_reader :exercise

    def exercise_needs_updating?
      exercise_config_modified? || exercise_files_modified?
    end

    def exercise_config_modified?
      return false unless track_config_modified?

      exercise_config[:slug] != exercise.slug ||
        # TODO: enable the line underneath when (if?) practice exercises have names
        # exercise_config[:name] != exercise.title ||
        !!exercise_config[:deprecated] != exercise.deprecated ||
        exercise_config[:prerequisites].sort != exercise.prerequisites.map(&:slug).sort
    end

    def exercise_files_modified?
      head_git_exercise.non_ignored_absolute_filepaths.any? { |filepath| filepath_in_diff?(filepath) }
    end

    def find_concepts(slugs)
      slugs.map do |slug|
        concept_config = concepts_config.find { |e| e[:slug] == slug }
        ::Track::Concept.find_by!(uuid: concept_config[:uuid])
      end
    end

    memoize
    def exercise_config
      # TODO: determine what to do when the exercise could not be found
      practice_exercises_config.find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
