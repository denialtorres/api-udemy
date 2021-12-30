# frozen_string_literal: true

class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end

  include JsonapiErrorsHandler
  ErrorMapper.map_errors!({
                            "ActiveRecord::RecordNotFound" => "JsonapiErrorsHandler::Errors::NotFound"
                          })
  rescue_from ::StandardError, with: ->(e) { handle_error(e) }

  rescue_from ActiveRecord::RecordInvalid, with: ->(e) { handle_validation_error(e) }

  rescue_from UserAuthenticator::Oauth::AuthenticationError, with: :authentication_oauth_error
  rescue_from UserAuthenticator::Standard::AuthenticationError, with: :authentication_standard_error
  rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize!

  private

  def authorize!
    raise AuthorizationError unless current_user
  end

  def access_token
    provide_token = request.authorization&.gsub(/\ABearer\s/, "")
    @access_token = AccessToken.find_by(token: provide_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def authorization_error
    error = {
      "status" => "403",
      "source" => { "pointer" => "/headers/authorization" },
      "title" => "Not authorized",
      "detail" => "You have no right to access this resource."
    }
    render json: { errors: [error] }, status: 403
  end

  def authentication_oauth_error
    error = {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" => "Authentication code is invalid",
      "detail" => "You must provide valid code in order to exchange it for token"
    }
    render json: { errors: [error] }, status: 401
  end

  def authentication_standard_error
    error = {
      status: "401",
      source: { pointer: "/data/attributes/password" },
      title: "Invalid login or password",
      detail: "You must provide valid credentials in order to exchange them for token"
    }
    render json: { "errors" => [error] }, status: 401
  end

  def handle_validation_error(error)
    error_model = error.try(:model) || error.try(:record)
    mapped = JsonapiErrorsHandler::Errors::Invalid.new(errors: error_model.errors)
    render_error(mapped)
  end
end
