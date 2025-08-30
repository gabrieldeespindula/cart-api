class ApplicationJob < ActiveJob::Base
  queue_as :default
  sidekiq_options retry: false
end
