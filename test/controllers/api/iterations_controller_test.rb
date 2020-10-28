require_relative './base_test_case'

class API::IterationsControllerTest < API::BaseTestCase
  ###
  # CREATE
  ###
  test "create should return 401 with incorrect token" do
    post api_solution_iterations_path(1, submission_id: 1), headers: @headers, as: :json
    assert_response 401
  end

  test "create should 404 if the solution doesn't exist" do
    setup_user
    post api_solution_iterations_path(999, submission_id: create(:submission)), headers: @headers, as: :json
    assert_response 404
  end

  test "create should 404 if the submission doesn't exist" do
    setup_user
    post api_solution_iterations_path(create(:concept_solution).uuid, submission_id: 999), headers: @headers, as: :json
    assert_response 403
  end

  test "create should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    submission = create :submission, solution: solution
    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid), headers: @headers, as: :json
    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should 404 if the submission doesn't belong to the solution" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission
    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "submission_not_found",
      message: I18n.t('api.errors.submission_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should return serialized iteration" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission, solution: solution

    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid),
      headers: @headers,
      as: :json

    assert_response :success
    expected = {
      iteration: {
        idx: 1
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create submission" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission, solution: solution

    Iteration::Create.expects(:call).with(solution, submission).returns(create(:iteration))

    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid),
      headers: @headers,
      as: :json

    assert_response :success
  end
end