class AddNsfwTagsToModels < ActiveRecord::Migration
  def change
    add_column :questions,  :nsfw, :boolean, default: false
    add_column :answers,    :nsfw, :boolean, default: false
    add_column :users,      :nsfw, :boolean, default: false
    add_column :users, :show_nsfw, :boolean, default: false
  end
end
