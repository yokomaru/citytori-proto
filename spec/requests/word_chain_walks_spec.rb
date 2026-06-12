require 'rails_helper'

RSpec.describe "WordChainWalks", type: :request do
  describe "POST /word_chain_walks" do
    context "散歩を作成する場合" do
      it "作成が成功すること" do
        expect do
          post word_chain_walks_path
        end.to change(WordChainWalk, :count).by(1)

        last_word_chain_walk = WordChainWalk.order(:id).last
        expect(last_word_chain_walk.start_char).to be_present
        expect(last_word_chain_walk.started_at).to be_present
        expect(response).to redirect_to(word_chain_walk_path(last_word_chain_walk))
      end
    end
  end
end
