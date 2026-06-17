# frozen_string_literal: true

class AddNotNullToStartedAtInWordChainWalks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :word_chain_walks, :started_at, false
  end
end
