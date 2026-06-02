class CompletionsController < ApplicationController
  def show
    # 本当はモーダルなので検討する
    @word_chain_walk = WordChainWalk.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
    from_time = @word_chain_walk.started_at
    to_time   = @word_chain_walk.finished_at

    total_seconds = (to_time - from_time).to_i # => 11745 秒

    hours   = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    @spend_time = "#{hours}時間 #{minutes}分 #{seconds}秒"
  end

  def update
    logger.debug "hi!"
    logger.debug "@word_chain_walk: #{@word_chain_walk}"
    @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
    if @word_chain_walk.update(finished_at: Time.zone.now)
        redirect_to word_chain_walk_completion_path(word_chain_walk_id: @word_chain_walk), notice: "Word chain walk was successfully updated.", status: :see_other
    else
        render :edit, status: :unprocessable_content
    end
  end
end
