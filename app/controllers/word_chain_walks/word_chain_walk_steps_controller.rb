# frozen_string_literal: true

module WordChainWalks
  class WordChainWalkStepsController < ApplicationController
    before_action :set_word_chain_walk_step, only: %i[show]

    # GET /word_chain_walk_steps/1 or /word_chain_walk_steps/1.json
    def show
      @initial_char = @word_chain_walk_step.word[0]
    end

    # GET /word_chain_walk_steps/new
    def new
      @word_chain_walk = WordChainWalk.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
      @word_chain_walk_step = WordChainWalkStep.new(word_chain_walk_id: params[:word_chain_walk_id])
    end

    def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])

      @word_chain_walk_step =
        @word_chain_walk.word_chain_walk_steps.build(word_chain_walk_step_params)

      if @word_chain_walk_step.save
        if @word_chain_walk_step.word.end_with?('ん') # TODO: 正規化必要&本当はモデルに寄せたい
          @word_chain_walk.update!(finished_at: Time.zone.now)

          redirect_to word_chain_walk_completion_path(@word_chain_walk),
                      notice: 'しりとり散歩が完了しました',
                      status: :see_other
        else
          respond_to do |format|
            format.turbo_stream
            format.html do
              redirect_to word_chain_walk_path(@word_chain_walk),
                          notice: '言葉を登録しました'
            end
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render :create, status: :unprocessable_entity
          end

          format.html do
            @word_chain_walk_steps =
              @word_chain_walk.word_chain_walk_steps
                              .with_attached_image
                              .order(id: :desc)

            @locations =
              @word_chain_walk.word_chain_walk_steps
                              .where.not(latitude: nil, longitude: nil)
                              .order(id: :desc)
                              .pluck(:latitude, :longitude)

            render 'word_chain_walks/show', status: :unprocessable_entity
          end
        end
      end
    end

    def destroy_latest
      @word_chain_walk = WordChainWalk.find(params[:word_chain_walk_id])
      latest_step = @word_chain_walk.latest_step

      if latest_step
        latest_step.destroy!
        redirect_to word_chain_walk_path(@word_chain_walk), notice: '一手前の言葉を削除しました', status: :see_other
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
      params.require(:word_chain_walk_step).permit(:word, :memo, :latitude, :longitude, :image)
    end
  end
end
