class UserStocksController < ApplicationController
  before_action :set_user_stock, only: %i[ show edit update destroy ]

  # GET /user_stocks or /user_stocks.json
  def index
    @user_stocks = UserStock.all
    @categories = Category.all

    # Initialise sort and filter
    session[:sort_list_by] = params[:sort_list_by]
    session[:filter_by] = params[:filter_by]

    # TO DO
    # make checkbox persistent in front end based onb filter by session
    # make sort n filter works together doesnt matter the order of execution


    sort_list_by
    filter_by
  end

  # GET /user_stocks/1 or /user_stocks/1.json
  def show
  end

  # GET /user_stocks/new
  def new
    @user_stock = UserStock.new
    @user_stock.batches.build
  end

  # GET /user_stocks/1/edit
  def edit
  end

  # POST /user_stocks or /user_stocks.json
  def create
    @user_stock = UserStock.new(user_stock_params)

    respond_to do |format|
      if @user_stock.save
        format.html { redirect_to @user_stock, notice: "User stock was successfully created." }
        format.json { render :show, status: :created, location: @user_stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_stocks/1 or /user_stocks/1.json
  def update
    respond_to do |format|
      if @user_stock.update(user_stock_params)
        format.html { redirect_to @user_stock, notice: "User stock was successfully updated." }
        format.json { render :show, status: :ok, location: @user_stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_stocks/1 or /user_stocks/1.json
  def destroy
    @user_stock.destroy
    respond_to do |format|
      format.html { redirect_to user_stocks_url, notice: "User stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Sort
    def sort_list_by
      case session[:sort_list_by]
      when "Exp Date (Earliest)"
        @user_stocks = UserStock.includes(:batches).order("batches.expiry ASC")
      when "Exp Date (Latest)"
        @user_stocks = UserStock.includes(:batches).order("batches.expiry DESC")
      when "Qty (Least)"
        @user_stocks = UserStock.includes(:batches).order("batches.quantity ASC")
      when "Qty (Most)"
        @user_stocks = UserStock.includes(:batches).order("batches.quantity DESC")
      when "Stock Name (A-Z)"
        @user_stocks = UserStock.order("name ASC")
      when "Stock Name (Z-A)"
        @user_stocks = UserStock.order("name DESC")
      when "Category Name (A-Z)"
        @user_stocks = UserStock.includes(:category).order("categories.name ASC")
      when "Category Name (Z-A)"
        @user_stocks = UserStock.includes(:category).order("categories.name DESC")
      end
    end
    
    # Filter
    def filter_by
      # Only check cats that have user_stock(s)
      @categories_filter = []
      @user_stocks.each do |stock|
        @categories_filter << stock.category.name
      end
      @categories_filter.uniq!

      if session[:filter_by] == nil
        filter_by = @categories_filter
      else
        filter_by = session[:filter_by]
      end

      @user_stocks = UserStock.includes(:category).where("categories.name" => filter_by)
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_user_stock
      @user_stock = UserStock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_stock_params
      params.require(:user_stock).permit(:name, :image, :category_id, :user_id, batches_attributes: [:expiry, :quantity])
    end
end
