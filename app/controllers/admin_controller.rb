class AdminController < ApplicationController
	before_filter :is_admin, except: [:login]

	def index
		@parameters = get_world().Parameters.find(:all, :order => :param)
		@parameters << Parameter.find_by_param("pass")
	end

	def save
		for p in get_world().Parameters.all
			value = params[p.param]

			if p.value != value
				if p.param == "algo_subject"
					clear_subject_data
				end

				p.value = value
				p.save
			end
		end

		value = params["pass"]
		p = Parameter.find_by_param("pass")
		if p.value != value
			p.value = value
			p.save
		end

		flash[:success] = "Parameters saved"
		redirect_to :action => "index"
	end

	def clear_subject_data
		subjects = get_world().Tests.all

		ActiveRecord::Base.transaction do
			for s in subjects
				s.subject_data = nil
				s.save
			end
		end
	end

	def login
		pass = params[:pass]

		return if not pass
		if pass == get_parameter("pass")
			session[:pass] = pass
			session[:world] = World.first.id
			redirect_to '/admin'
		else
			flash[:error] = "Login error"
		end
	end

	def logout
		session[:pass] = nil
		session[:world] = nil

		redirect_to '/admin'
	end
end
