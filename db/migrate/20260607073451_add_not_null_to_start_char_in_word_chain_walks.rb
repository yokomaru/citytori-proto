class AddNotNullToStartCharInWordChainWalks < ActiveRecord::Migration[8.1]
  def change
      change_column_null :word_chain_walks, :start_char, false
  end
end
