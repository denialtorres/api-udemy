class AccessTokensController < ApplicationController
  skip_before_action :authorize!, only: :create

  def create
    authenticator = UserAuthenticator.new(authentication_params)

    authenticator.perform

    render json: serializer.new(authenticator.access_token), status: :created
  end

  def destroy
    current_user.access_token.destroy
  end

  private

  def serializer
    AccessTokenSerializer
  end

  def authentication_params
    params.permit(:code).to_h.symbolize_keys
  end
end
