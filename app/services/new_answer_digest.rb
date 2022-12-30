class NewAnswerDigest
  include Delayed::RecurringJob

  def perform(answer)
    send_digest(answer)
  end

  private

  def send_digest(answer)
    answer.question.subscribers.each do |user|
      NewAnswerDigestMailer.digest(answer, user.email).deliver_later
    end
  end
end
