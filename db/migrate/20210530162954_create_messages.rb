# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :content

      t.timestamps
    end
  end
end
