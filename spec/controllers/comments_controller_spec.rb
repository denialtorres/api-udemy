require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:article) { create(:article) }

  describe 'GET /index' do
    subject { get :index, params: { article_id: article.id } }

    it 'renders a successful response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return only comments belonging to an article' do
      comment = create(:comment, article: article)
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it 'should paginate results' do
      comment_1, comment_2, comment_3 = create_list(:comment, 3, article: article)
      get :index, params: { article_id: article.id, page: { number: 2, size: 1 } }
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment_2.id.to_s)
    end

    it 'returns a proper json' do
      comment = create(:comment, article: article)
      subject
      expect(json_data.length).to eq(1)
      expected = json_data.first
      aggregate_failures do
        expect(expected[:id]).to eq(comment.id.to_s)
        expect(expected[:type]).to eq('comments')
        expect(expected[:attributes]).to eq(
          content: comment.content
        )
      end
    end

    it 'should have related objects information in the response' do
      comment = create(:comment, article: article)
      create :comment
      subject
      relationships = json_data.first[:relationships]
      aggregate_failures do
        expect(relationships[:article][:data][:id]).to eq(comment.article_id.to_s)
        expect(relationships[:user][:data][:id]).to eq(comment.user_id.to_s)
      end
    end
  end

  describe 'POST /create' do
    context 'when not authorized' do
      subject { post :create, params: { article_id: article.id } }
      it_behaves_like 'forbidden_request'
    end

    context 'when authorized' do
      let(:valid_attributes) do
        { data: { attributes: { content: 'My awesome comment for article' } } }
      end
      let(:invalid_attributes) { { data: { attributes: { content: '' } } } }

      let(:user) { create(:user) }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'with valid parameters' do
        subject do
          post :create, params: valid_attributes.merge(article_id: article.id)
        end

        it 'creates a new Comment' do
          expect { subject }.to change(article.comments, :count).by(1)
        end

        it 'returns 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'renders a JSON response with the new comment' do
          subject
          expect(json_data).to include(valid_attributes[:data])
        end
      end

      context 'with invalid parameters' do
        subject do
          post :create, params: invalid_attributes.merge(article_id: article.id)
        end

        it 'does not create a new Comment' do
          expect { subject }.to change(Comment, :count).by(0)
        end

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json[:errors]).to include(
            {
              status: 422,
              title: 'Invalid request',
              detail: "content can't be blank",
              source: { pointer: '/data/attributes/content' }
            }
          )
        end
      end
    end
  end
end
