require 'rails_helper'

RSpec.describe WordChainWalkStep, type: :model do

  it "has a valid factory" do
    expect(FactoryBot.build(:word_chain_walk_step)).to be_valid
  end

  describe "validations" do
    describe "word" do
      it "is valid with a word" do
        word_chain_walk_step = FactoryBot.build(:word_chain_walk_step)
        expect(word_chain_walk_step).to be_valid
      end

      it "is invalid without a word" do
        word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: nil)
        expect(word_chain_walk_step).to be_invalid
      end

      it "is invalid when word is 100 characters or more" do
        word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: "あ" * 101)
        expect(word_chain_walk_step).to be_invalid
      end

      it "is valid when word contains only hiragana and prolonged sound mark" do
        word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: "あいうえおー")
        expect(word_chain_walk_step).to be_valid
      end

      it "is invalid when word contains katakana" do
        word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, word: "アイウエオ")
        expect(word_chain_walk_step).to be_invalid
      end
    end
  end
end
