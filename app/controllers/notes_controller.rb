class NotesController < ApplicationController

  def show

  end

  def create
    @note = Note.new(note_params)
    respond_to do |format|
      if @note.save
        format.json { render status: :created, location: @note }
      else
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @notes = Note.all
  end

  private

  def note_params
    params.require(:note).permit(:message)
  end

end
