# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Error pages', type: :request do
  error_pages = {
    '400.html' => 'Bad request',
    '404.html' => 'Page not found',
    '406-unsupported-browser.html' => 'Browser not supported',
    '422.html' => 'Request not completed',
    '500.html' => 'Something went wrong'
  }

  describe 'static pages in public/' do
    error_pages.each do |filename, title|
      context filename do
        subject(:html) { Rails.public_path.join(filename).read }

        it 'is branded with the logo' do
          expect(html).to include('src="/error-logo.png"')
          expect(html).to include('alt="Freddies Keepsakes"')
        end

        it 'shows a friendly title' do
          expect(html).to include("<h1>#{title}</h1>")
          expect(html).to include("<title>#{title}")
        end

        it 'links back into the site' do
          expect(html).to include('href="/"')
          expect(html).to include('href="/store"')
        end

        it 'is kept out of search engines' do
          expect(html).to include('<meta name="robots" content="noindex, nofollow">')
        end

        it 'does not load any assets that could themselves fail' do
          expect(html).not_to match(/<link[^>]+rel="stylesheet"/)
          expect(html).not_to include('<script')
        end
      end
    end

    it 'ships the logo they reference' do
      expect(Rails.public_path.join('error-logo.png')).to exist
    end
  end

  describe 'serving the pages for real errors' do
    # Behave like production: render the public error pages instead of
    # raising or showing the debug page.
    before do
      allow(Rails.application).to receive(:env_config).and_wrap_original do |original|
        original.call.merge(
          'action_dispatch.show_exceptions' => :all,
          'action_dispatch.show_detailed_exceptions' => false
        )
      end
    end

    it 'shows the branded 404 page for a missing page' do
      get '/this-page-does-not-exist'

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('<h1>Page not found</h1>', 'src="/error-logo.png"')
    end

    it 'shows the branded 404 page for a missing product' do
      get '/products/no-such-product'

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('<h1>Page not found</h1>')
    end

    it 'shows the branded 422 page for a rejected request' do
      allow_any_instance_of(HomeController).to receive(:index).and_raise(ActionController::InvalidAuthenticityToken)

      get store_path

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('<h1>Request not completed</h1>')
    end

    it 'shows the branded 500 page for an unexpected error' do
      allow_any_instance_of(HomeController).to receive(:index).and_raise(StandardError, 'boom')

      get store_path

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include('<h1>Something went wrong</h1>', 'src="/error-logo.png"')
      expect(response.body).not_to include('boom')
    end
  end
end
