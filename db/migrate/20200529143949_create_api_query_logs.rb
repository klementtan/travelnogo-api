class CreateApiQueryLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :api_query_logs do |t|
      t.string :controller
      t.string :action
      t.string :response
      t.integer :status
      t.string :params

      t.timestamps
    end
  end
end
