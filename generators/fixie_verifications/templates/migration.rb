class AddFixieVerifications < ActiveRecord::Migration
  def self.up
    create_table :fixie_verifications do |t|
      t.column :relation_id, :integer, :null => false
      t.column :relation_type, :string, :null => false
      t.column :verified_at, :datetime
      t.column :code, :string, :null => false
      t.column :email, :string, :null => false
    end
    add_index :fixie_verifications, [:relation_id, :relation_type, :code]
    add_index :fixie_verifications, :code
  end

  def self.down
    drop_table :fixie_verifications
  end
end
