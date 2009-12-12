class ObjectsSite < ActiveRecord::Base
	belongs_to :site
	belongs_to :object, :polymorphic => true
end
