class NewAnswerDigestJob < ApplicationJob
  def perform(*_args)
    DailyDigest.new.perform
  end
end
