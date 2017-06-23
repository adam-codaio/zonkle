require 'util'

desc "Import initial algorithms"
task :algo => [:environment] do
	Algorithm.create({
		:atype => ALGO_SUBJECT,
		:name => "control",
		:desc => "Control - subjects do not interact",
		:algo => <<-eos

		return nil
	eos

	})

	Algorithm.create({
	  :atype => ALGO_SUBJECT,
	  :name => "linear",
	  :desc => "Linear sequencing - each subject interacts only with the previous subject",
	  :algo => <<-eos

	return Test.last
eos
	})

	Algorithm.create({
	  :atype => ALGO_SUBJECT,
	  :name => "cohesion",
	  :desc => "Cohesion - each subjects is likely to interact with equal likelihood with any of the previous subjects",
	  :algo => <<-eos

        subjects = Test.all
        return subjects[rand(subjects.length)]
eos
	})

	Algorithm.create({
	  :atype => ALGO_SUBJECT,
	  :name => "inequality",
	  :desc => "Inequality - probabilities are drawn from a fixed log-normal distribution such that the probability is long-tailed with a few subjects having high likelihood of interaction and a majority having little likelihood.",
	  :algo => ""
	})

	Algorithm.create({
	  :atype => ALGO_SUBJECT,
	  :name => "clustered",
	  :desc => "Clustered - n is likely to interact with members of her group with equal probability, and is likely to interact with members of the other group with a smaller but nonzero equal probability.",
	  :algo => ""
	})
end
