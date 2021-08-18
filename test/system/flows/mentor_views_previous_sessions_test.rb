require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class MentorViewsPreviousSessionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "mentor views previous session" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student-123"

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      lasagna_discussion = create :mentor_discussion, :finished, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      create :mentor_student_relationship, mentor: mentor, student: student, num_discussions: 2

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        click_on "See 1 previous session"

        assert_text "You have 1 previous discussion"
        assert_text "student-123"
        assert_link "Lasagna", href: Exercism::Routes.mentoring_discussion_url(lasagna_discussion)
      end
    end

    test "mentor favorites a student" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student-123"
      create :mentor_student_relationship, mentor: mentor, student: student, num_discussions: 2

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        click_on "See 1 previous session"
        within(".m-mentoring-sessions") { click_on "Add to favorites" }

        assert_text "Favorited"
      end
    end
  end
end
