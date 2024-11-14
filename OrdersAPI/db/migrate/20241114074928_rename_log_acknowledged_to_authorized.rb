class RenameLogAcknowledgedToAuthorized < ActiveRecord::Migration[8.0]
  def change
    rename_column :logs, :is_acknowledged, :is_authorized
  end
end
