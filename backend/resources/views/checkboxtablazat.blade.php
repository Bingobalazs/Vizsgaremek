<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fákjú</title>
</head>
<body>
    <?php
        for ($i = 0; $i < 4; $i++)
        {
            for ($j = 0; $j < 4; $j++)
            {
                $selected = $t[$j][$i] == 1 ? 'checked' : '';
                echo '<input ' . $selected . ' type="checkbox" onchange="Ment(' . $i . ',' . $j . ', event)">';
            }
            echo '<br>';
        }
    ?>
</body>
</html>
<script>

    function HTTPRequest(url, callback)
    {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
                if (callback != null) callback(this.responseText)
            };
        };
        xhttp.open("GET", url, true);
        xhttp.send();
    }

    function Ment(sor, oszlop)
    {
        let ertek = event.target.checked ? '1' : '0';
        HTTPRequest('/tablazatmentes/' + sor + '/' + oszlop + '/' + ertek);
    }

</script>