require 'rails_helper'

RSpec.describe "WordChainWalks::WordChainWalkSteps", type: :request do
  describe "DELETE /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/latest" do
    let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, start_char: "り") }

    context "ステップが存在する場合" do
      it "ステップが削除されること" do
        old_step = FactoryBot.create(:word_chain_walk_step, :with_image,  word_chain_walk: word_chain_walk, word: "りんご")
        latest_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "ごりら")

        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.to change(WordChainWalkStep, :count).by(-1)

        expect(WordChainWalkStep.exists?(old_step.id)).to be true
        expect(WordChainWalkStep.exists?(latest_step.id)).to be false
        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end
    end

    context "ステップが存在しない場合" do

      it "ステップが削除されないこと" do
        word_chain_walk = FactoryBot.create(:word_chain_walk)

        # DELETE /latest を送る
        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.to change(WordChainWalkStep, :count).by(0)

        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end
    end
  end
end
