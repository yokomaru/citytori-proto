class WordChainWalks::WordChainWalkStepsController < ApplicationController
  before_action :set_word_chain_walk_step, only: %i[ show ]

  # GET /word_chain_walk_steps/1 or /word_chain_walk_steps/1.json
  def show
    @initial_char = @word_chain_walk_step.word[0]
  end

  # GET /word_chain_walk_steps/new
  def new
    @word_chain_walk = WordChainWalk.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
    @word_chain_walk_step = WordChainWalkStep.new(word_chain_walk_id: params[:word_chain_walk_id])
  end

  # POST /word_chain_walk_steps or /word_chain_walk_steps.json
  def create
    @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.new(word_chain_walk_step_params)

    if @word_chain_walk_step.save
      if @word_chain_walk_step.word.end_with?("ん") #TODO: 正規化必要&本当はモデルに寄せたい
        @word_chain_walk.update!(finished_at: Time.zone.now )
        redirect_to word_chain_walk_completion_path(word_chain_walk_id: @word_chain_walk), notice: "Word chain walk was successfully updated.", status: :see_other
      else
        redirect_to word_chain_walk_path(@word_chain_walk), notice: "Word chain walk step was successfully created."
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy_latest
    @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
    latest_step = @word_chain_walk.latest_step

    if latest_step
      latest_step.destroy!
      redirect_to word_chain_walk_path(@word_chain_walk), notice: "一手前の言葉を削除しました", status: :see_other
    else
      word_chain_walk = WordChainWalk.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
      @word_chain_walk_steps = word_chain_walk.word_chain_walk_steps.order(id: :desc)
      redirect_to word_chain_walk_path(@word_chain_walk), status: :see_other
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_word_chain_walk_step
    @word_chain_walk_step = WordChainWalkStep.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def word_chain_walk_step_params
    params.require(:word_chain_walk_step).permit(:word, :memo, :index, :latitude, :longitude, :word_chain_walk_id, :image)
  end
end
