class Answer < ApplicationRecord
  include PgSearch
  multisearchable against: :body

  after_save :reindex

  belongs_to :question, touch: true
  belongs_to :author, class_name: "User"
  has_many :links, dependent: :destroy, as: :linkable
  has_many :comments, dependent: :destroy, as: :commentable
  has_many :votes
  has_many :voted_users, through: :votes, source: :user

  accepts_nested_attributes_for :links, reject_if: :all_blank

  has_many_attached :files

  validates :body, presence: true

  def current_vote(user)
    votes.find_by(user:)
  end

  def likes
    { true => 0, false => 0 }.merge(votes.group(:like).count)
  end

  def rating
    likes[true] - likes[false]
  end

  private

  def reindex
    PgSearch::Multisearch.rebuild(Answer)
  end
end
