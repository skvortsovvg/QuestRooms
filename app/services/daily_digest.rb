class DailyDigest
  include Delayed::RecurringJob
  run_every 1.day

  def perform(answer)
    send_digest(answer)
  end

  private

  def send_digest
    @new_questions = Question.where('created_at >= ? AND created_at <= ?', Date.current, Date.tomorrow)
    User.find_each(batch_size: 500) do |user|
      DailyDigestMailer.digest(user).deliver_later
    end
  end
end
