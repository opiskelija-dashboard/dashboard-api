# Example of how to run complicated queries against complicated data
# without having to implement a programming language within a programming
# language, Or, How I Learned To Stop Overcoding And Love Kernel#eval


# The data for this example file: five points and five users.
points = [
	{"exercise_id"=>90, "awarded_point"=>{"name"=>"01_20", "submission_id"=>998, "course_id"=> 300, "id"=>999, "user_id"=>2, "created_at"=>"2007-01-01T12:00:00"}},
	{"exercise_id"=>91, "awarded_point"=>{"name"=>"01_21", "submission_id"=>988, "course_id"=> 300, "id"=>989, "user_id"=>2, "created_at"=>"2007-01-01T12:08:00"}},
	{"exercise_id"=>91, "awarded_point"=>{"name"=>"01_20", "submission_id"=>978, "course_id"=> 300, "id"=>979, "user_id"=>3, "created_at"=>"2007-01-01T12:03:00"}},
	{"exercise_id"=>90, "awarded_point"=>{"name"=>"01_20", "submission_id"=>978, "course_id"=> 300, "id"=>979, "user_id"=>3, "created_at"=>"2007-01-01T12:39:00"}},
	{"exercise_id"=>90, "awarded_point"=>{"name"=>"01_20", "submission_id"=>978, "course_id"=> 300, "id"=>979, "user_id"=>4, "created_at"=>"2007-01-01T11:30:00"}},
]

Users = [1, 2, 3, 4]

# Our badge definition code. In actuality these strings of Ruby code would
# be stored in the badge/achievement definition YAML file/other conf file.
done_one_exercise = %q(
	found = false
	all_points.each do |raw_point|
		found = true if (raw_point["awarded_point"]["user_id"] == user_id);
	end
	found # We're not allowed to do a "return" here
);

done_two_exercises = %q(
	exercises_done = 0
	all_points.each do |raw_point|
		exercises_done += 1 if (raw_point["awarded_point"]["user_id"] == user_id);
	end
	(exercises_done >= 2)
);

# This imitates the badge definition configuration file.
Badges = [
	{ "badge_name" => "Done one exercise", "badge_code" => done_one_exercise },
	{ "badge_name" => "Done two exercises", "badge_code" => done_two_exercises }
	# ...
]


# Giving this function a user_id and an array of all points gives us back
# a Binding object, which stores the execution environment of inside the
# function, most importantly the values passed to the function.
# We can later use this to run a stringful of Ruby as if it were inside
# the function.
def achievement_predication_environment(user_id, all_points)
	return binding() # calls Kernel#binding
end

Users.each do |user_id|
	Badges.each do |badge_def|
		# here also check if user has already been given the badge
		# next if user_has_badge?(user_id, badge)

		# Create a Binding with the current user id and all points.
		binding = achievement_predication_environment(user_id, points);

		# Run the test in the context of the Binding.
		got_achievement = eval(badge_def["badge_code"], binding);

		# If the test passed (the eval'd code evaluated to true),
		# do stuff.
		if (got_achievement)
			# in actuality replace this with tunge_tietokantaan(user, badge)
			puts("User " + user_id.to_s + " got achievement '" + badge_def["badge_name"] + "'");
		end
	end
end
