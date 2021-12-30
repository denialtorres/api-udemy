# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :authorize!, only: [:index]
  before_action :load_article

  include Paginable
  # GET /comments
  def index
    comments = @article.comments
    paginated = paginate(comments)

    render_collection(paginated)
  end

  # POST /comments
  def create
    comment = @article.comments.build(comment_params.merge(user: current_user))
    comment.save!
    render json: serializer.new(comment), status: :created
  end

  private

  def serializer
    CommentsSerializer
  end

  def load_article
    @article = Article.find(params[:article_id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:data)
          .require(:attributes)
          .permit(:content)
  end
end
