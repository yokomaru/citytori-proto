class WordChainWalkStep < ApplicationRecord
  belongs_to :word_chain_walk

  has_one_attached :image

  validates :word, presence: true
  validates :word, length: { maximum: 100 }
  validates :word, format: { with: /\A[ぁ-んー]*\z/ }

  validate :must_connect_previous_char
  validate :must_not_add_steps_to_finished_word_chain_walk

  validate :image_attached

  private

  def image_attached
    errors.add(:image, "を添付してください") unless image.attached?
  end

  def must_connect_previous_char
    return if word.blank?

    if word_chain_walk.target_char != word[0] # TODO: 本当はword[0]を正規化する必要がある
      errors.add(:word, "と前の文字が繋がっていません")
    end
  end

  def must_not_add_steps_to_finished_word_chain_walk
    return if word.blank?
    if word_chain_walk.finished?
      errors.add(:word, "は終了済みのしりとり散歩には追加できません")
    end
  end
end
