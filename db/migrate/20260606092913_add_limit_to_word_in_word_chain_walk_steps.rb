# frozen_string_literal: true

class AddLimitToWordInWordChainWalkSteps < ActiveRecord::Migration[8.1]
  def up
    change_column :word_chain_walk_steps, :word, :string, limit: 100
  end

  def down
    change_column :word_chain_walk_steps, :word, :string, limit: 255
  end
end
