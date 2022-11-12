class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :author, class_name: "User"
  has_one :best_answer, class_name: "Answer"
  has_one_attached :file
  validates :title, :body, presence: true

  scope :answers_best_first, -> (qst) { qst.answers.where(id: qst.best_answer) + qst.answers.where.not(id: qst.best_answer) }
end
