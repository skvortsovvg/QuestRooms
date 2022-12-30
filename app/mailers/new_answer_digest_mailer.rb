class NewAnswerDigestMailer < ApplicationMailer
  def digest(answer, email)
    @answer = answer
    mail to: email
  end
end
