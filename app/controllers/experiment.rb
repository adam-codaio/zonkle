####################
# This file has main experiment logic.
#
# RankedLabel has a pointer to an actual label and stores the times it was
# presented to the user (outdeg) and the times it was chosen (indeg) per
# experiment.  The rank and probability is then calculated.
#
class RankedLabel
	attr_accessor :label, :indeg, :outdeg, :rank, :prob

	def initialize(label)
		@label  = label
		@indeg  = 0.0
		@outdeg = 0.0
		@rank   = 0.0
		@prob   = 0.0
	end

	def to_s()
		return "id #{@label}" \
			 " indeg #{@indeg}" \
			 " outdeg #{@outdeg}" \
			 " rank #{@rank}" \
			 " prob #{@prob}"
	end

	def ==(other)
		return self.label == other.label \
			&& self.indeg == other.indeg \
			&& self.outdeg == other.outdeg \
			&& self.rank == other.rank \
			&& self.prob == other.prob
	end
end

#####################
# World selection
#
def choose_world()
	open = []
	worlds = World.all

	# can probably use SQL
	for w in worlds
		done = w.Tests.count
		max = w.Parameters.find_by_param("participants").value.to_i
		open << w if max == 0 or done < max
	end

	return nil if open.empty?

	return open[rand(open.length)]
end

#####################
# Subject selection
#
# I.e., who will the next test be based on?
#
def choose_subject(world)
	return nil if world.Tests.last == nil

	algo = get_parameter("algo_subject")

	# XXX in future let admins edit algorithm and run Algorithm.algo
	ret = eval("choose_subject_#{algo}(world)")

	return ret
end

def choose_subject_control(world)
	return nil
end

def choose_subject_linear(world)
	subject = world.Tests.last

	return subject
end

def choose_subject_cohesion(world)
	subjects = world.Tests.all

	return subjects[rand(subjects.length)]
end

# copied from Python lognormvariate
NV_MAGICCONST = 4.0 * Math.exp(-0.5) / Math.sqrt(2.0)

def normalvariate(mu, sigma)
	while true
		u1 = rand()
		u2 = 1.0 - rand()
		z  = NV_MAGICCONST * (u1 - 0.5) / u2
		zz = z * z / 4.0
		if zz <= - Math.log(u2)
			return mu + z * sigma
		end
	end
end

def choose_subject_inequality(world)
	subjects = world.Tests.all

	mu    = 0.0
	sigma = 0.25

	tot = 0.0
	for s in subjects
		if (s.subject_data == nil)
			r = Math.exp(normalvariate(mu, sigma))
			s.subject_data = r
			s.save
		end

		r = s.subject_data.to_f
		tot += r
	end

	r = rand()
	c = 0.0

	for s in subjects
		p  = s.subject_data.to_f / tot
		c += p

		return s if r <= c
	end

	return subjects[-1]
end

def choose_subject_clustered(world)
	subjects = world.Tests.all
	groups = { 0 => [], 1 => [] }

	for s in subjects
		if (s.subject_data == nil)
			s.subject_data = rand(2)
			s.save
		end

		r = s.subject_data.to_i
		groups[r] << s
	end

	r = rand(2)

	n = subjects.length.to_f
	b = 1.0 / n
	b = b / 2.0

	cn = groups[r].length.to_f
	c = (1.0 - b * (n - cn)) / cn

	p = 0.0
	x = rand()

	for s in groups[r]
		p += c
		return s if x <= p
	end

	other = 0
	other = 1 if r == 0
	for s in groups[other]
		p += b
		return s if x <= p
	end

	return groups[other][-1]
end

####################
# Grab the explicit label for the next test
#
def explicit_label(world, subject)
	if subject == nil
		l = world.Labels.where(:seed => true)

		rnd = rand(l.length)
		l = l[rnd]
	else
		l = subject.end_label
	end

	return l.desc
end

#####################
# Calculations for Input labels for next test start here
#
def start_labels(world, subject)
	if subject == nil
		labels = []

		seed = world.Labels.where(:seed => true)
		for s in seed
			l = RankedLabel.new(s.id)
			l.indeg = 1.0
			labels << l
		end

		return labels
	end

	labels = {}

	results = subject.TestResults
	for r in results
		for res in ["labela_id", "labelb_id"]
			id = r[res]

			label = labels[id] \
				|| labels[id] = RankedLabel.new(id)

			if id == r.choice_id
				label.indeg  += 1
			else
				label.outdeg += 1
			end
		end
	end

	# XXX assume all input labels make it to results

	return labels.values()
end

def rank_labels(labels)
	for label in labels
		label.rank = label.indeg / (label.indeg + label.outdeg)
	end
end

def calculate_probabilities(labels)
	tot = 0

	for label in labels
		tot += label.rank
	end

	for label in labels
		label.prob = label.rank / tot
	end
end

def get_ranked_labels(world, subject)
	labels = start_labels(world, subject)
	rank_labels(labels)
	return labels
end

def add_end_label(subject, labels)
	return if subject == nil

	min = max = labels[0]
	mins = []

	for l in labels
		return if l.label == subject.end_label_id

		max = l if l.rank > max.rank

		if l.rank < min.rank
			min  = l
			mins = []
		end

		mins << l if l.rank == min.rank
	end

	min = mins[rand(mins.length)]
	x = labels.delete(min)

	e = get_parameter("e").to_f
	rank = max.rank + e

	label = RankedLabel.new(subject.end_label_id)
	label.rank = rank

	labels << label
end

def input_labels(world, subject)
	labels = get_ranked_labels(world, subject)
	#add_end_label(subject, labels)
	calculate_probabilities(labels)

	return labels
end

##################
# Calculate the pairs shown to users based on label probabilities
#
def pairs(labels)
	unpicked = labels.dup
	picked   = {}
	items    = []
	n        = get_parameter("N").to_i

	while picked.length < n
		picks = pick_labels(labels, unpicked)

		ids = picks.map(&:label)

		key = ids.to_set
		next if picked.has_key?(key)

		picked[key] = ids
		items << ids
	end

	return items
end

def pick_labels(labels, unpicked)
	picks = []

	while picks.length < 2
		r = rand()

		from = unpicked.empty? ? labels : unpicked
		idx  = pick_label(from, r)

		if from == unpicked
			picks << unpicked.delete_at(idx)
			next
		end

		if not picks.empty?
			next if picks[0] == labels[idx]
		end

		picks << labels[idx]
	end

	return picks
end

def pick_label(labels, rnd)
	ctr = 0.0
	idx = 0

	while true
		idx = 0
		ctrold = ctr
		for label in labels
			ctr += label.prob

			return idx if rnd < ctr

			idx += 1
		end

		# all 0 prob - return rand
		if ctrold == ctr
			return rand(labels.length)
		end
	end
end
