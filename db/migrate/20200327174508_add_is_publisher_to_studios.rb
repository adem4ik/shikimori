class AddIsPublisherToStudios < ActiveRecord::Migration[5.2]
  def change
    add_column :studios, :is_publisher, :boolean, default: false, null: false
  end
end
