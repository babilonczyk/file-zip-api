class CreateUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :uploads do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
