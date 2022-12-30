class AnswersController < ApplicationController
  before_action :set_question, only: %i[create]
  before_action :set_answer, except: %i[create new_comment publish_answer]
  after_action :publish_answer, :send_digest, only: [:create]

  authorize_resource

  def create
    @answer = @question.answers.create(answer_params.merge(author: current_user))
  end

  def edit
    @answer.links.new
  end

  def update
    @answer.update(answer_params)
  end

  # or dislike
  def like
    vote = @answer.current_vote(current_user)
    like = params[:like]

    if !vote
      @answer.votes.create(user: current_user, like:)
    elsif vote.like.to_s == like
      vote.destroy
    else
      vote.update(like:)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json do
        render json: {
          answer_id: @answer.id,
          rating: @answer.rating,
          html: render_to_string(partial: 'answers/likes', locals: { answer: @answer }, formats: [:html])
        }
      end
    end
  end

  def publish_answer
    return if @answer.errors.any?

    AnswerChannel.broadcast_to(@answer.question,
                               { html: ApplicationController.render(
                                 partial: 'answers/answer',
                                 locals: { answer: @answer, current_user: }
                               ),
                                 answer_id: @answer.id,
                                 current_user: current_user.id,
                                 author_id: @answer.author.id })
  end

  def new_comment
    @answer = Answer.find(params[:answer_id])
    @comment = @answer.comments.create(comment_params.merge(author: current_user))
    publish_comment
  end

  def publish_comment
    return if @comment.errors.any?

    CommentChannel.broadcast_to(@answer.question,
                                { html: ApplicationController.render(
                                  partial: 'comments/comment',
                                  locals: { comment: @comment }
                                ),
                                  commentable_type: @comment.commentable_type,
                                  commentable_id: @comment.commentable_id,
                                  comment_id: @comment.id,
                                  author_id: @comment.author.id })
  end

  def delete_file
    @file_id = params[:file_id]
    @answer.files.find_by(id: @file_id).purge
  end

  def destroy
    if @answer.author == current_user
      @answer.destroy
      # redirect_to question_path(@answer.question), notice: "Answer was successfully deleted."
    else
      @answer.errors.add(:access, "Access denied! Only author can delete it!")
      # redirect_to root_path, alert: "Access denied! Only author can delete it!"
    end
  end

  private

  def send_digest
    NewAnswerDigest.new.delay.perform(@answer)
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: %i[id name url])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
