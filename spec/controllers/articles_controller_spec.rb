require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe '#index' do
    subject { get :index }

    it 'returns a success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns a proper json' do
      article = create(:article)
      subject
      expect(json_data.length).to eq(1)
      expected = json_data.first
      aggregate_failures do
        expect(expected[:id]).to eq(article.id.to_s)
        expect(expected[:type]).to eq('article')
        expect(expected[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end

    it 'returns articles in the proper order' do
      older_article = create(:article,
                             created_at: 1.hour.ago)
      recent_article = create(:article, slug: generate(:slug))
      subject
      ids = json_data.map { |item| item[:id].to_i }

      expect(ids).to eq([recent_article.id, older_article.id])
    end

    it 'paginates results' do
      article_1, article_2, article_3 = create_list(:article, 3)
      get :index, params: { page: { number: 2, size: 1 } }
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(article_2.id.to_s)
    end

    it 'contains pagination links in the response' do
      article_1, article_2, article_3 = create_list(:article, 3)
      get :index, params: { page: { number: 2, size: 1 } }
      expect(json[:links].length).to eq(5)
      expect(json[:links].keys).to contain_exactly(:first, :prev, :next, :last, :self)
    end
  end

  describe '#show' do
    let(:article) { create(:article) }
    subject { get :show, params: { id: article.id } }

    before { subject }

    it 'returns a success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a proper JSON' do
      aggregate_failures do
        expect(json_data[:id]).to eq(article.id.to_s)
        expect(json_data[:type]).to eq('article')
        expect(json_data[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no code proved' do
      it_behaves_like 'forbidden_request'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization_error'] = 'Invalid token' }
      it_behaves_like 'forbidden_request'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end

        subject { post :create, params: invalid_attributes }

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
              detail: "title can't be blank",
              source: { pointer: '/data/attributes/title' }
            }
          )
        end
      end

      context 'when sucess request sent' do
        let(:valid_attributes) do
          {
            data: {
              attributes: {
                title: generate(:title),
                content: 'this is a super content',
                slug: generate(:slug)
              }
            }
          }
        end

        subject { post :create, params: valid_attributes }

        it 'should have 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have proper json body data' do
          subject
          expect(json_data).to include(valid_attributes[:data])
        end

        it 'should crete the article' do
          expect { subject }.to change { Article.count }.by(1)
        end
      end
    end
  end
end
