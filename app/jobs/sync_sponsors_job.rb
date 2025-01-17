# The goal of this job is to re-sync the sponsors to guard against
# one of the GitHub webhook calls failing, which would result in our
# sponsors data not being correct
class SyncSponsorsJob < ApplicationJob
  queue_as :dribble

  def perform = Github::Sponsors::Sync.()
end
