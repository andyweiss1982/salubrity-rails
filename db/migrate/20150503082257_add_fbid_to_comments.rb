class AddFbidToComments < ActiveRecord::Migration
  def change
    add_column :comments, :fbid, :string
  end
end
