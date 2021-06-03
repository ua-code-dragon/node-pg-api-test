var _after = 0;

function bootstrap_index(){
    $(document).ready(function() {
        setInterval(() => {
            $.ajax({
                cache: false,
                type: 'POST',
                url: '/ntest/api/data',
                datatype : 'json',
                data: {
                    after: _after,
                    limit: 32
                },
                success: (resp) => {
                    _after = resp.slice(-1)[0].id;
                    resp.forEach((x) => {
                        var dt = $("#datable")[0];
                        if(dt.rows){
                            if(dt.rows.length >= 36)
                                dt.deleteRow(dt.rows.length - 1);
                            var r = dt.insertRow(1);
                            var c = r.insertCell(0);
                            c.innerHTML = new Date(x.moment).toUTCString();
                            var c = r.insertCell(1);
                            c.innerHTML = Number.parseFloat(x.x).toFixed(6);
                            var c = r.insertCell(2);
                            c.innerHTML = Number.parseFloat(x.y).toFixed(6);
                            var c = r.insertCell(3);
                            c.innerHTML = Number.parseFloat(x.z).toFixed(6);
                        }
                    });
                }
            });
        }, 3000);
    });
}


function bootstrap_login(){
    $(document).ready(function() {
        $("#loginbtn").click((e) => {
            e.preventDefault();
            $.ajax({
                cache: false,
                type: 'POST',
                url: '/ntest/api/login',
                data: $("#login").serialize(),
                datatype : 'json',
                success: (resp) => {
                    $(location).attr('href', '/ntest');
                }
            });    
        });
    });
}
