class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      user.admin ? amdin_abilities : user_abilities(user)
    else
      guest_abilities
    end
  end

  private

  def guest_abilities
    can :read, :all
  end

  def amdin_abilities
    can :manage, :all
  end

  def user_abilities(user)
    guest_abilities
    can :create, [Question, Answer, Comment]
    can :update, [Question, Answer, Comment], author: user
    can :destroy, [Question, Answer, Comment], author: user
    can :subscribe, Question
    can :like, Answer
  end
end
