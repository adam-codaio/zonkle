class Label < ActiveRecord::Base
  attr_accessible :desc, :seed
  belongs_to :world

  validates :desc, length: { maximum: 30 }
end
