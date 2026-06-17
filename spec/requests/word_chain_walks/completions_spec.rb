# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WordChainWalks::Completions', type: :request do
  describe 'PATCH  /word_chain_walks/:word_chain_walk_id/completion' do
    let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, start_char: 'り') }

    it '散歩が終了すること' do
      expect do
        patch word_chain_walk_completion_path(word_chain_walk)
      end.to change { word_chain_walk.reload.finished? }.from(false).to(true)

      expect(response).to redirect_to(word_chain_walk_completion_path(word_chain_walk))
    end
  end
end
