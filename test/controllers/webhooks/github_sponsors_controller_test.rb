require_relative './base_test_case'

class Webhooks::GithubSponsorsControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      action: 'created',
      sponsorship: {
        sponsor: {
          login: 'user22'
        }
      }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    ProcessGithubSponsorUpdateJob.expects(:perform_later).never

    post webhooks_github_sponsors_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    payload = {
      action: 'created',
      sponsorship: {
        sponsor: {
          login: 'user22'
        }
      }
    }

    ProcessGithubSponsorUpdateJob.expects(:perform_later).with('created', 'user22')

    post webhooks_github_sponsors_path, headers: headers(payload), as: :json, params: payload
    assert_response :no_content
  end
end
