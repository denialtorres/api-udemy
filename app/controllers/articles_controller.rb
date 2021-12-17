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
    article = current_user.articles.build(article_params)
    article.save!
    render json: serializer.new(article), status: :created
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: serializer.new(article), status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  end

  private

  def serializer
    ArticleSerializer
  end

  def article_params
    params.require(:data)
          .require(:attributes)
          .permit(:title, :content, :slug)
  end
end
