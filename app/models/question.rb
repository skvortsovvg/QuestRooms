class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_many :comments, dependent: :destroy, as: :commentable
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  belongs_to :author, class_name: "User"
  belongs_to :best_answer, class_name: "Answer", optional: true
  belongs_to :regard, optional: true

  accepts_nested_attributes_for :links, :regard, reject_if: :all_blank

  has_many_attached :files

  validates :title, :body, presence: true

  scope :answers_best_first, ->(qst) { qst.answers.where(id: qst.best_answer_id) + qst.answers.where.not(id: qst.best_answer_id) }
end
