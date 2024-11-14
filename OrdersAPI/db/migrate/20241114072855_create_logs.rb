class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :logs do |t|
      t.references :order, null: false, foreign_key: true
      t.boolean :is_refund
      t.decimal :amount
      t.boolean :is_acknowledged

      t.timestamps
    end
  end
end
