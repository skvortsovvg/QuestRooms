class DailyDigestJob < ApplicationJob
  def perform(*_args)
    DailyDigest.new.perform
  end
end
