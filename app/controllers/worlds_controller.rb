require 'csv'

class WorldsController < ApplicationController
	before_filter :is_admin

	def index
		@current = session[:world]
		@worlds = World.all
	end

	def create
		world = World.create

		setup_world(world)

		flash[:success] = "World #{world.id} created"

#		do_switch(world.id)
		redirect_to :action => "index"
	end

	def do_switch(id)
		session[:world] = id

		redirect_to :action => "index"
	end

	def destroy
                id = params[:id]

		# XXX confirm

		World.destroy(id)

		session[:world] = World.first.id if id.to_i == session[:world].to_i

#		flash[:success] = "World #{id} deleted"

		redirect_to :action => "index"
	end

	def switch
                id = params[:id]

#		flash[:success] = "Switching to world #{id}"

		do_switch(id)
	end

	def download
		csvf = CSV.generate do |csv|
			csv << ["World ID", "Test ID", "Label A", "Label B",
				"Choice", "Start", "End", "Prev Subject"]

			for w in World.all
				dump_world(csv, w)
			end
		end

		send_data(csvf, :type => 'text/csv', :filename => 'zonkle.csv') 
	end

	def dump_world(csv, world)
		for t in world.Tests
			dump_test(csv, t)
		end
	end

	def dump_test(csv, test)
		for r in test.TestResults
			dump_result(csv, r)
		end
	end

	def dump_result(csv, result)
		test  = result.test
		world = test.world

		la = world.Labels.find(result.labela_id).desc
		lb = world.Labels.find(result.labelb_id).desc
		lc = world.Labels.find(result.choice_id).desc

		ls = test.explicit_label.desc
		le = test.end_label.desc

		s = test.subject
		if s
			s = s.id
		else
			s = "none"
		end

		csv << [world.id, test.id, la, lb,
			lc, ls, le, s]
	end
end
