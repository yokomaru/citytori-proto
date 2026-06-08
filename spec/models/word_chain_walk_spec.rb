require 'rails_helper'

RSpec.describe WordChainWalk, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:word_chain_walk)).to be_valid
  end

  it 'start_charが空の時は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: nil)
    expect(word_chain_walk).to be_invalid
  end

  it 'start_charがひらがなで1文字場合は有効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: "り")
    expect(word_chain_walk).to be_valid
  end

  it 'start_charがひらがなで1文字だが小文字の場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: "ぁ")
    expect(word_chain_walk).to be_invalid
  end

  it 'start_charがひらがなで2文字の場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: "ぁ")
    expect(word_chain_walk).to be_invalid
  end

  it 'start_charがひらがな以外で2文字以上場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: "ABC")
    expect(word_chain_walk).to be_invalid
  end

  it 'started_atが空の時無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: nil)
    expect(word_chain_walk).to be_invalid
  end

  it 'finished_atが空の場合は有効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, finished_at: nil)
    expect(word_chain_walk).to be_valid
  end

  it 'finished_atがstarted_atより前の時は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: Time.zone.local(2026, 6, 2, 10, 0, 0), finished_at: Time.zone.local(2026, 6, 1, 10, 0, 0))
    expect(word_chain_walk).to be_invalid
  end

  it 'ランダムなひらがな1文字が帰ってくること' do
    word_chain_walk = WordChainWalk.new(started_at: Time.zone.local(2026, 6, 2, 10, 0, 0))

    expect(word_chain_walk.start_char).to match(/\A[あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわを]\z/)
  end
end
