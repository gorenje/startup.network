class CreateSocialEntityLookup < ActiveRecord::Migration
  def change
    create_table :social_entity_lookups do |t|
      t.string :provider
      t.text :url
      t.belongs_to :entity, :index => true
    end

    add_index :social_entity_lookups, [:provider, :url]
  end
end
