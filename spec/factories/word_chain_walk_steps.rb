FactoryBot.define do
  factory :word_chain_walk_step do
    word { "あいうえお" }
    association :word_chain_walk
  end
end
