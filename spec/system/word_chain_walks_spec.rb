require 'rails_helper'

RSpec.describe "WordChainWalks", type: :system do
  before do
    driven_by(:rack_test)
  end
  scenario "ユーザーは散歩を開始して言葉を登録して完了できること" do
    visit root_path

    expect do
      click_button "始める"
      expect(page).to have_content "Word chain walk was successfully created."
    end.to change(WordChainWalk, :count).by(1)

    last_word_chain_walk = WordChainWalk.order(:id).last

    expect do
      click_link "写真を撮る"
      expect(page).to have_content "#{last_word_chain_walk.start_char} を探しましょう"

      fill_in "Word", with: "#{last_word_chain_walk.start_char}は"
      attach_file "Image", Rails.root.join("spec/fixtures/files/480x320.png")
      click_button "Create Word chain walk step"

    end.to change(WordChainWalkStep, :count).by(1)

    expect do
      click_on "散歩を完了する"
    end.to change { last_word_chain_walk.reload.finished? }.from(false).to(true)

    expect(page).to have_content "しりとり散歩が\n完了しました"
    # 後で追加する
    # 経過時間
    # Step数
  end
end
