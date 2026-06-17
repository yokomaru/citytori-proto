# frozen_string_literal: true

class AddIsPublicToWordChainWalks < ActiveRecord::Migration[8.1]
  def change
    add_column :word_chain_walks, :is_public, :boolean, default: false, null: false
  end
end
