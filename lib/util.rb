ALGO_SUBJECT = 1

def get_parameter(param)
	params = Parameter
	params = get_world().Parameters if param != "pass"

	return params.find_by_param(param).value
end

def is_logged_in()
	return session[:pass] == get_parameter("pass")
end

def is_admin()
	return if is_logged_in()

	redirect_to '/admin/login'
end

def get_world()
	return World.find(session[:world])
end

def setup_world(w)
	setup_parameters(w)
	setup_labels(w)
end

def setup_parameters(w)
        w.Parameters.create({:param => "N",
                          :desc => "Number of comparisons",
                          :value => "30"
                        })

        w.Parameters.create({:param => "e",
                          :desc => "End label rank boost",
                          :value => "0.1"
                        })

        w.Parameters.create({:param => "JW",
                          :desc => "Jaro-Winkler confidence when matching labels",
                          :value => "0.80"
                        })

        w.Parameters.create({:param => "algo_subject",
                          :desc => "Subject selection algorithm",
                          :value => "linear"
                        })

        w.Parameters.create({:param => "participants",
                          :desc => "Number of participants",
                          :value => "0"
                        })
end

def setup_labels(w)
        labels = [ "Backyard",
                   "Party",
                   "Rental",
                   "Space",
                   "Local",
                   "Web",
                   "Connect",
                   "Community",
                   "Smartphone",
                   "Environmental",
                   "Social",
                   "Money saving",
                   "House-sharing",
                   "Convenient",
                   "Fun" ]

        for l in labels
                w.Labels.create({:desc => l, :seed => true})
        end
end
