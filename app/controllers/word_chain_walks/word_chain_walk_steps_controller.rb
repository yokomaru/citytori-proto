class WordChainWalks::WordChainWalkStepsController < ApplicationController
  def latest
    @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
    logger.debug "@word_chain_walk: #{@word_chain_walk}"
    logger.debug "@word_chain_walk.word_chain_walk_steps.last: #{@word_chain_walk.word_chain_walk_steps.last}"
    if @word_chain_walk.word_chain_walk_steps.last.present?
      @word_chain_walk.destroy!
      redirect_to word_chain_walks_path(@word_chain_walk), notice: "Word chain walk was successfully destroyed.", status: :see_other
    end
  end
end
