# frozen_string_literal: true

class CreateWordChainWalkSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :word_chain_walk_steps do |t|
      t.string :word
      t.text :memo
      t.integer :index
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :word_chain_walk, null: false, foreign_key: true

      t.timestamps
    end
  end
end
