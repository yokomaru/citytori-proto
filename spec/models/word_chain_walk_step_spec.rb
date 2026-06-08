require 'rails_helper'

RSpec.describe WordChainWalkStep, type: :model do
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, start_char: "り") }

  it "has a valid factory" do
    expect(FactoryBot.build(:word_chain_walk_step)).to be_valid
  end

  it "wordがなければ無効であること" do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: nil)
    expect(word_chain_walk_step).to be_invalid
  end

  it "wordが101文字以上の場合は無効であること" do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: "あ" * 101)
    expect(word_chain_walk_step).to be_invalid
  end

  it "wordがひらがなと伸ばし棒のみの場合は有効であること" do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: "あいうえおー")
    expect(word_chain_walk_step).to be_valid
  end

  it "wordにカタカナが含まれる場合は無効であること" do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: "アイウエオ")
    expect(word_chain_walk_step).to be_invalid
  end

  it "1件目のwordが散歩の開始文字から始まる場合は有効であること" do
    next_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: "りんご")
    expect(next_step).to be_valid
  end

  it "1件目のwordが散歩の開始文字から始まらない場合は無効であること" do
    next_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: "ごりら")
    expect(next_step).to be_invalid
  end

  it "2件目以降のwordが直前のwordの最後の文字から始まる場合は有効であること" do
    FactoryBot.create(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: "りんご")
    second_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: "ごりら")
    expect(second_step).to be_valid
  end

  it "2件目以降のwordが直前のwordの最後の文字から始まらない場合は無効であること" do
    FactoryBot.create(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: "りんご")
    second_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: "らっぱ")
    expect(second_step).to be_invalid
  end
end
