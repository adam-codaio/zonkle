require 'fuzzystringmatch'

class LabelsController < ApplicationController
        before_filter :is_admin, except: [:find ]

	def index
		w = get_world()
		@labels = w.Labels
	end

	def destroy
		id = params[:id]
		force = params[:force]

		if not force and (Test.find_by_explicit_label_id(id) or \
		   Test.find_by_end_label_id(id) or \
		   TestResult.find_by_labela_id(id) or \
		   TestResult.find_by_labelb_id(id))
		   	@label = Label.find(id)
			render :confirmdel
			return
		end

		Label.destroy(id)
		redirect_to :action => "index"
	end

	def new
		@label = Label.new
	end

	def create
		label = get_world().Labels.create(params[:label])
		label.seed = true
		label.save

		redirect_to :action => "index"
	end
	
	###############
	# Used in the "did you mean?" calculation
	#
	# Return null if we need no correction - either a new label, or an
	# existing one was specified.
	#
	def find
		lab = params[:label].downcase

		labels = Label.all.map { |l| l.desc.downcase }

		ret = nil

		confidence = get_parameter("JW").to_f

		if not labels.include? lab
			scores = {}

			jarow = FuzzyStringMatch::JaroWinkler.create(:native)

			for l in labels
				scores[l] = jarow.getDistance(l, lab)
			end

			winner = scores.sort_by {|_key, value| value}.reverse
			winner = winner[0]

#			print("Winner is #{winner}\n")
			ret = winner[0] if winner[1] >= confidence
		end

		res = { "match" => ret }

		render :json => res.as_json()
	end
end
