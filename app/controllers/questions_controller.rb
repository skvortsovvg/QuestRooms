class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_question, except: %i[index new create new_comment]
  after_action :publish_question, only: [:create]

  authorize_resource

  def index
    @questions = Question.all
  end

  def new
    @question = current_user.questions.new
    @question.links.new
    @question.build_regard
  end

  def best
    @question.update(best_answer_id: params[:answer_id])
    redirect_to question_path(@question)
  end

  def create
    @question = current_user.questions.new(question_params)
    if @question.save
      current_user.subscribed_questions << @question
      redirect_to question_path(@question)
    else
      render :new
    end
  end

  def new_comment
    @question = Question.find(params[:question_id])
    @comment = @question.comments.create(comment_params.merge(author: current_user))
  end

  def show
    @new_answer = @question.answers.new
    @new_answer.links.new
  end

  def delete_file
    @file_id = params[:file_id]
    @question.files.find_by(id: @file_id).purge
  end

  def delete_link
    @link_id = params[:link_id]
    @question.links.find_by(id: @link_id).destroy
  end

  def update
    @question.update(question_params)
  end

  def destroy
    if @question.author == current_user
      @question.destroy
      redirect_to root_path, notice: "Question was successfully deleted."
    else
      redirect_to question_path(@question), alert: "Access denied! Only author can delete it!"
    end
  end

  def subscribe
    if current_user.has_subscribtion?(@question)
      @question.subscribers.destroy(current_user)
    else
      @question.subscribers << current_user
    end
  end

  private

  def publish_question
    return if @question.errors.any?

    ActionCable.server.broadcast 'questions',
                                 ApplicationController.render(
                                   partial: 'questions/question_card',
                                   locals: { question: @question, current_user: }
                                 )
  end

  def set_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [], regard_attributes: %i[name image], links_attributes: %i[id name url])
  end
end
