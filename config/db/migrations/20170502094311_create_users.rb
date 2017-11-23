class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     :name
      t.string     :email
      t.boolean    :email_verified
      t.text       :credentials
      t.string     :salt
      t.string     :confirm_token
      t.boolean    :has_confirmed, :default => false
      t.timestamps :null => false
    end
  end
end
