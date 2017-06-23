_other = true;

function check_endlabel()
{
       if (!_other)                                                                                         
                return true;

        other = $("#other").val();

//      $("#finish").val("Checking label...");

        $.getJSON('/labels/find', { 'label' : other }, function(data) {
//              $("#finish").val("Finish");

                match = data['match'];

                if (match == null) {
                        do_submit();
                } else {
                        $("#meanstuff").show();
                        $("#mean").html(match);
                        _other = false;
                }
        });

        return false;
}

function do_mean()
{
        mean = $("#mean").html();
        $("#other").val(mean);
        do_submit();
}

function do_submit()
{
        _other = false;
        $("#form").submit();
}
