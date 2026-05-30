class WordChainWalk < ApplicationRecord
  has_many :word_chain_walk_steps, dependent: :destroy
end
