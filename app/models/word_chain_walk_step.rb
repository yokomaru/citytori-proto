class WordChainWalkStep < ApplicationRecord
  belongs_to :word_chain_walk

  has_one_attached :image

  validates :word, presence: true
  validates :word, length: { maximum: 100 }
  validates :word, format: { with: /\A[ぁ-んー]*\z/ }

  validate :must_connect_previous_char

  def must_connect_previous_char
    return if word.blank?

    previous_step = word_chain_walk.word_chain_walk_steps.order(:id).last
    # TODO: 本当はword[-1]を正規化する必要がある
    previous_char = previous_step.present? ? previous_step.word[-1] : word_chain_walk.start_char
    if previous_char != word[0]
      errors.add(:word, "と前の文字が繋がっていません")
    end
  end
end
