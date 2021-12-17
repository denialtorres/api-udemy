# servicer that handles the whole authentication logic
class UserAuthenticator::Oauth < UserAuthenticator
  attr_reader :user, :code, :access_token

  def initialize(code)
    @code = code
  end

  def perform
    raise AuthenticationError if code.blank?
    raise AuthenticationError if token.try(:error).present?

    prepare_user

    @access_token = if user.access_token.present?
                      user.access_token
                    else
                      user.create_access_token
                    end
  end

  private

  def token
    @token ||= client.exchange_code_for_token(code)
  end

  def client
    @client ||= Octokit::Client.new(
      client_id: 'x',
      client_secret: 'x'
    )
  end

  def user_data
    @user_data ||= Octokit::Client.new(
      access_token: token
    ).user.to_h.slice(:login, :avatar, :url, :name)
  end

  def prepare_user
    @user = if User.exists?(login: user_data[:login])
              User.find_by(login: user_data[:login])
            else
              User.create(user_data.merge(provider: 'github'))
            end
  end
end