class World < ActiveRecord::Base
  attr_accessible :title, :start

  has_many :Labels, :dependent => :destroy
  has_many :Tests, :dependent => :destroy
  has_many :Parameters, :dependent => :destroy
end
