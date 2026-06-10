require 'rails_helper'

RSpec.describe "WordChainWalks::WordChainWalkSteps", type: :request do
describe "DELETE /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/latest" do

    context "ステップが存在する場合" do
      before do
        @project = FactoryBot.create(:project)
      end

      it "ステップが削除されること" do

        # WordChainWalkを作る
        # 古いStepを作る
        # 最新Stepを作る

        # DELETE /latest を送る

        # Stepの件数が1減ること
        # 最新Stepが削除されていること
        # 古いStepは残っていること
        # 正しい画面へリダイレクトすること

        # expect do
        #   delete project_path(@project)
        # end.to change(Project, :count).by(-1)
        # expect(response).to redirect_to(projects_path)
      end
    end

    context "ステップが存在しない場合" do
      before do
        @project = FactoryBot.create(:project)
      end

      it "ステップが削除されないこと" do
        # WordChainWalkだけ作る

        # DELETE /latest を送る

        # Stepの件数が変わらないこと
        # 正しい画面へリダイレクトすること
        # expect do
        #   delete project_path(@project)
        # end.to change(Project, :count).by(-1)
        # expect(response).to redirect_to(projects_path)
      end
    end
  end
end
