class Test < ActiveRecord::Base
  attr_accessible :explicit_label_id, :subject_data
  serialize :input_labels
  has_many :TestResults, :dependent => :destroy
  belongs_to :world

  belongs_to :explicit_label, :class_name => 'Label', \
  		:foreign_key => 'explicit_label_id'

  belongs_to :end_label, :class_name => 'Label', :foreign_key => 'end_label_id'

  belongs_to :subject, :class_name => 'Test', :foreign_key => 'subject_id'
end
