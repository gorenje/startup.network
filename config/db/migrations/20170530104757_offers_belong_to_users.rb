class OffersBelongToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :offers, :user_id, :integer
    remove_column :offers, :email, :string
    add_index :offers, :user_id
  end
end
