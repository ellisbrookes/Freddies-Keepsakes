# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Homepage', type: :request do
  it 'renders the homepage at the root with a link to the store' do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response).to render_template('landing/index', layout: 'layouts/storefront')
    expect(response.body).to include(%(href="#{store_path}"))
  end

  it 'serves the shop at /store' do
    get store_path

    expect(response).to have_http_status(:ok)
    expect(response).to render_template('home/index')
  end
end
