class CreateObjectsSite < ActiveRecord::Migration
  def self.up
    create_table :objects_sites do |t|
      t.references :site
      t.references :object, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :objects_sites
  end
end
