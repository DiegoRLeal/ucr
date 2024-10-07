# app/jobs/mains_job.rb
class MainsJob
  include Sidekiq::Worker

  def perform
    MainsController.new.job
  end
end
