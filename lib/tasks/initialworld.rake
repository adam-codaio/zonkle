desc "Initial world setup"
task :initialworld => [:environment] do
	w = World.create
	setup_world(w)

	Parameter.create({:param => "pass",
			  :desc => "Admin password",
			  :value => "w00t"
			})
end
