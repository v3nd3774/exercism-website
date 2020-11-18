require 'test_helper'

class Submission::RepresentationTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:submission_representation, ops_status: 199).ops_success?
    assert create(:submission_representation, ops_status: 200).ops_success?
    refute create(:submission_representation, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:submission_representation, ops_status: 199).ops_errored?
    refute create(:submission_representation, ops_status: 200).ops_errored?
    assert create(:submission_representation, ops_status: 201).ops_errored?
  end

  test "exercise_representation" do
    exercise = create :concept_exercise
    ast = "My AST"
    ast_digest = Submission::Representation.digest_ast(ast)

    representation = create :submission_representation,
      submission: create(:submission, exercise: exercise),
      ast_digest: ast_digest

    # Wrong exercise
    create :exercise_representation,
      exercise: create(:concept_exercise),
      ast_digest: Submission::Representation.digest_ast(ast)
    assert_raises do
      representation.exercise_representation
    end

    # Wrong ast
    create :exercise_representation,
      exercise: exercise,
      ast_digest: "something"

    assert_raises do
      representation.exercise_representation
    end

    # Correct everything!
    exercise_representation = create :exercise_representation,
      exercise: exercise,
      ast_digest: ast_digest
    assert_equal exercise_representation, representation.exercise_representation
  end
end
