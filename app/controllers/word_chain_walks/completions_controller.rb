# frozen_string_literal: true

module WordChainWalks
  class CompletionsController < ApplicationController
    def show
      # 本当はモーダルなので検討する
      @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
    end

    def update
      @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
      if @word_chain_walk.update(finished_at: Time.zone.now)
        redirect_to word_chain_walk_completion_path(word_chain_walk_id: @word_chain_walk),
                    notice: 'Word chain walk was successfully updated.', status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end
  end
end
