function check_world_busy()
{
        $.getJSON('/tests/busy', function(data) {
		busy = data['busy']

		if (busy) {
			setTimeout(function() { check_world_busy(); }, 5000);
		} else {
			$("#retry").submit()
		}
        });
}
