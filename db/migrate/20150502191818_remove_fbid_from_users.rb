class RemoveFbidFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :fbid, :string
  end
end
