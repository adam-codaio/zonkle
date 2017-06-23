require 'experiment'

class TestsController < ApplicationController
        before_filter :is_admin, only: [:index, :show, :destroy ]

	#################################
	# User-facing test execution
	#
	def home
	end

	def desc
		render :layout => false
	end

	def new
		if request.post?
			if params[:retry]
				start_test()
			else
				start_new_test()
			end
		end

		@explicit_label = session[:explicit]
	end

	def start_new_test()
		reset_session

		world = choose_world()
		if world == nil
			flash[:error] = "The site is closed for new surveys"
                	redirect_to '/'
			return
		end

		session[:world] = world.id

		start_test()
	end

	def start_test()
		world = get_world()

		if world_busy()
                	redirect_to :action => "wait"
		end

		# XXX race
		world.start = Time.now
		world.save

		subject = choose_subject(world)
		labels  = input_labels(world, subject)

		session[:subject]       = subject ? subject.id : nil
		session[:explicit]      = explicit_label(world, subject)
		session[:input_labels]  = labels.map(&:label)
		session[:pairs] 	= pairs(labels)
	end

	def wait
	end

	def world_busy()
		w = get_world()

		return false if w.start == nil

		el = Time.now - w.start

		max = 600
		return false if el >= max

		return true
	end

	def busy()
		res = { "busy" => world_busy() }
		render :json => res.as_json()
	end

	def start
		@items = []

		for pair in session[:pairs]
			labs = []

			for i in 0..1
				labs << Label.find(pair[i]).desc
			end

			@items << [labs[0], labs[1]]
		end
	end

	def save
		results = ActiveSupport::JSON.decode(params[:results])

		picked = {}
		labs = []

		for i in 0..(session[:pairs].length - 1)
			pair = session[:pairs][i]

			for lab in pair[0, 2]
				next if picked.has_key?(lab)
				picked[lab] = true
				labs << Label.find(lab).desc
			end

			pair << results[i][2] if pair.length < 3
		end

		@labels = labs
	end

	def create
		world = get_world()

		endl = params[:other]

		tmp = world.Labels.where(Label.arel_table[:desc].matches(endl))
		tmp = tmp.first
		if tmp == nil
			world.Labels.create({:desc => endl})
		else
			endl = tmp.desc
		end

		endl = world.Labels.find_by_desc(endl)
		exp  = world.Labels.find_by_desc(session[:explicit])

		ActiveRecord::Base.transaction do
			test = world.Tests.create
			test.explicit_label_id = exp.id
			test.end_label_id      = endl.id
			test.input_labels      = session[:input_labels]
			test.subject_id	       = session[:subject]
			test.ip		       = request.remote_ip
			test.browser = "#{browser.name}/#{browser.platform}"
			test.save

			for r in session[:pairs]
				labela = Label.find(r[0])
				labelb = Label.find(r[1])

				choice = labela
				choice = labelb if r[2] == 1

				result = test.TestResults.create
				result.labela_id = labela.id
				result.labelb_id = labelb.id
				result.choice_id = choice.id
				result.save
			end
		end

		world.start = nil
		world.save
	end

	#############################
	# Test admin
	#
	def index
		@tests = get_world().Tests.order("id DESC")
	end

	def show
		@test     = Test.find(params[:id])
		@explicit = @test.explicit_label.desc
		@endl     = @test.end_label.desc
		@subject  = @test.subject
		@results  = @test.TestResults
		@world    = @test.world

		# XXX there's randomness in input labels
		inl = @results.map(&:labela_id)
		inl.concat(@results.map(&:labelb_id))
		inl = inl.to_set
		while true
			@inlabels  = input_labels(@world, @subject)

			labs = @inlabels.map(&:label).to_set

			break if inl == labs
		end

		labels = get_ranked_labels(@world, @test)
		calculate_probabilities(labels)
		@outlabels = labels

		@nextlabels = input_labels(@world, @test)
	end

	def destroy
                id = params[:id]
                force = params[:force]
                
                if not force and Test.find_by_subject_id(id)
                        @test = Test.find(id)
                        render :confirmdel
                        return
                end
                
                Test.destroy(id)
                redirect_to :action => "index"
	end
end
