class Parameter < ActiveRecord::Base
  attr_accessible :desc, :param, :value
  belongs_to :world
end
