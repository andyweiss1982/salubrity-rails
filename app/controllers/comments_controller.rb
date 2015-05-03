class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :get_current_parse_user, except: [:index]
  skip_before_action :authenticate_user!, :only => [:index]

  # GET /comments
  # GET /comments.json
  def index
    if current_user
      good_ids = current_user.friend_ids
      good_ids << current_user.uid
      @comments = Comment.where(fbid: good_ids).order(created_at: :desc).limit(10)
    end
    @comments2 = Comment.order(created_at: :desc).limit(10)
  end

  def api
    # good_ids = current_user.friend_ids
    # good_ids << current_user.uid
    @comments = Comment.order(created_at: :desc).limit(10)
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    
    if @current_parse_user['anonymous'] == 'true'
      @author = 'Anonymous'
    else 
      @author = @current_parse_user['first_name']
    end
    
    @fbid = @current_parse_user['facebook_id']

    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to new_comment_path }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_url, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:author, :text, :fbid)
    end

    def get_current_parse_user
      @current_parse_user = current_user.parse_record
    end
end
