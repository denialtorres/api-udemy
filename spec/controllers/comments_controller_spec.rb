require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  let(:valid_session) do
    {}
  end

  describe 'GET /index' do
    let(:article) { create(:article) }

    it 'renders a successful response' do
      get :index, params: { article_id: article.id }, session: valid_session
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Comment' do
        expect do
          post :create,
               params: { comment: valid_attributes }, session: valid_session, as: :json
        end.to change(Comment, :count).by(1)
      end

      it 'renders a JSON response with the new comment' do
        post :create,
             params: { comment: valid_attributes }, session: valid_session, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Comment' do
        expect do
          post :create,
               params: { comment: invalid_attributes }, as: :json
        end.to change(Comment, :count).by(0)
      end

      it 'renders a JSON response with errors for the new comment' do
        post :create,
             params: { comment: invalid_attributes }, session: valid_session, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
