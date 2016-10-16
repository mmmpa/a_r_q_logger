class CreateTestChildModels < ActiveRecord::Migration
  def change
    create_table :test_child_models do |t|
      t.integer :test_model_id
      t.string :name

      t.timestamps null: false
    end
  end
end
