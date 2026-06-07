class AddNotNullToWordInWordChainWalkSteps < ActiveRecord::Migration[8.1]
  def change
    # テーブル名は複数形の :users、カラム名は :name
    change_column_null :word_chain_walk_steps, :word, false
  end
end
