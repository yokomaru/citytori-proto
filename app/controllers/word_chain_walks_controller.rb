class WordChainWalksController < ApplicationController
  before_action :set_word_chain_walk, only: %i[ show edit update destroy ]

  # GET /word_chain_walks or /word_chain_walks.json
  def index
    @word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).all
    @active_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).where(finished_at: nil)
    @completed_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).where.not(finished_at: nil)
  end

  # GET /word_chain_walks/1 or /word_chain_walks/1.json
  def show
  end

  # GET /word_chain_walks/new
  def new
    @word_chain_walk = WordChainWalk.new
  end

  # GET /word_chain_walks/1/edit
  def edit
  end

  # POST /word_chain_walks or /word_chain_walks.json
  def create
    @word_chain_walk = WordChainWalk.new(start_char: "あ", started_at: Time.zone.now)

    if @word_chain_walk.save
      redirect_to @word_chain_walk, notice: "Word chain walk was successfully created."
    else
      @word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).all
      @active_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).where(finished_at: nil)
      @completed_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).where.not(finished_at: nil)
      render :index, status: :unprocessable_content
    end
  end

  # PATCH/PUT /word_chain_walks/1 or /word_chain_walks/1.json
  def update
    respond_to do |format|
      if @word_chain_walk.update(word_chain_walk_params)
        format.html { redirect_to @word_chain_walk, notice: "Word chain walk was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @word_chain_walk }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @word_chain_walk.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /word_chain_walks/1 or /word_chain_walks/1.json
  def destroy
    @word_chain_walk.destroy!

    respond_to do |format|
      format.html { redirect_to word_chain_walks_path, notice: "Word chain walk was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word_chain_walk
      @word_chain_walk = WordChainWalk.find(params[:id])
    end

    # # Only allow a list of trusted parameters through.
    # def word_chain_walk_params
    #   params.require(:word_chain_walk).permit(:start_char, :started_at, :finished_at, is_public: )
    # end
end
