require 'rails_helper'

RSpec.describe WordChainWalkStep, type: :model do

  it "has a valid factory" do
    expect(FactoryBot.build(:word_chain_walk_step)).to be_valid
  end

  # describeもいらないかも
  describe "validations" do
    describe "word" do
      # いらないかも
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

    describe "word connects previous char" do
      before do
        @word_chain_walk = FactoryBot.create(:word_chain_walk, start_char: "り")
      end

      it "is valid when the first word starts with the walk's start character" do
        next_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: @word_chain_walk, word: "りんご")
        expect(next_step).to be_valid
      end

      it "is invalid when the first word does not start with the walk's start character" do
        next_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: @word_chain_walk, word: "ごりら")
        expect(next_step).to be_invalid
      end

      it "is valid when a subsequent word starts with the previous word's last character" do
        first_step = FactoryBot.create(:word_chain_walk_step, word_chain_walk: @word_chain_walk, word: "りんご")
        second_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: @word_chain_walk, word: "ごりら")

        expect(second_step).to be_valid
      end

      it "is invalid when a subsequent word does not start with the previous word's last character" do
        first_step = FactoryBot.create(:word_chain_walk_step, word_chain_walk: @word_chain_walk, word: "りんご")
        second_step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: @word_chain_walk, word: "らっぱ")

        expect(second_step).to be_invalid
      end
    end
  end
end
