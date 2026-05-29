class WordChainWalkStepsController < ApplicationController
  before_action :set_word_chain_walk_step, only: %i[ show edit update destroy ]

  # GET /word_chain_walk_steps or /word_chain_walk_steps.json
  def index
    @word_chain_walk_steps = WordChainWalkStep.all
  end

  # GET /word_chain_walk_steps/1 or /word_chain_walk_steps/1.json
  def show
  end

  # GET /word_chain_walk_steps/new
  def new
    @word_chain_walk_step = WordChainWalkStep.new
  end

  # GET /word_chain_walk_steps/1/edit
  def edit
  end

  # POST /word_chain_walk_steps or /word_chain_walk_steps.json
  def create
    @word_chain_walk_step = WordChainWalkStep.new(word_chain_walk_step_params)

    respond_to do |format|
      if @word_chain_walk_step.save
        format.html { redirect_to @word_chain_walk_step, notice: "Word chain walk step was successfully created." }
        format.json { render :show, status: :created, location: @word_chain_walk_step }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @word_chain_walk_step.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /word_chain_walk_steps/1 or /word_chain_walk_steps/1.json
  def update
    respond_to do |format|
      if @word_chain_walk_step.update(word_chain_walk_step_params)
        format.html { redirect_to @word_chain_walk_step, notice: "Word chain walk step was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @word_chain_walk_step }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @word_chain_walk_step.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /word_chain_walk_steps/1 or /word_chain_walk_steps/1.json
  def destroy
    @word_chain_walk_step.destroy!

    respond_to do |format|
      format.html { redirect_to word_chain_walk_steps_path, notice: "Word chain walk step was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
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
