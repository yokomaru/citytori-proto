class WordChainWalk < ApplicationRecord
  has_many :word_chain_walk_steps, dependent: :destroy

  validates :start_char, presence: true
  validates :start_char, length: { is: 1 }
  validates :start_char, format: { with: /\A[あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわを]*\z/ }

  validates :started_at, presence: true
  validates :finished_at, comparison: { greater_than: :started_at }, allow_nil: true
end
