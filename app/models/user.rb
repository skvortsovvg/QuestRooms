class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  has_many :questions, class_name: "Question", foreign_key: "author_id"
  has_many :answers, class_name: "Answer", foreign_key: "author_id"
  has_many :votes
  has_many :voted_answers, through: :votes, source: :answer
  has_many :authorizations, dependent: :destroy
  has_many :subscriptions
  has_many :subscribed_questions, through: :subscriptions, source: :question

  def admin?
    admin
  end

  def self.find_for_oauth(auth)
    FindForOauth.new(auth).call
  end

  def has_subscribtion?(question)
    subscribed_questions.include?(question)
  end
end
