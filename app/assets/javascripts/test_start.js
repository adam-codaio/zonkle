cur = -1;

function display_next(idx)
{
        if ((cur + 1) == labels.length) {
                $("#rform").submit();
                return;
        }

        if (idx >= 0) {
                res = $("#results");
                labels[cur].push(idx);
                $("#results").val(JSON.stringify(labels));
                res.val();                                                                                    
        }                                                                                                     

        cur++;

        $("#num").html("" + (cur + 1));
        $("#label1").html("" + labels[cur][0]);
        $("#label2").html("" + labels[cur][1]);
}
