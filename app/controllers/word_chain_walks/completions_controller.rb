class WordChainWalks::CompletionsController < ApplicationController
  def show
    # 本当はモーダルなので検討する
    @word_chain_walk = WordChainWalk.find(params[:id])
  end

  def update
    logger.debug "hi!2"
  end
end
