class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  include Paginable

  def index
    paginated = paginate(Article.recent)
    render_collection(paginated)
  end

  def show
    article = Article.find(params[:id])
    render json: serializer.new(article), status: :ok
  end

  def create
    article = Article.new(article_params)
    article.save!
  end

  private
  def serializer
    ArticleSerializer
  end

  def article_params
    ActionController::Parameters.new
  end
end
