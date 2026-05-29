class CreateWordChainWalks < ActiveRecord::Migration[7.1]
  def change
    create_table :word_chain_walks do |t|
      t.string :start_char
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
