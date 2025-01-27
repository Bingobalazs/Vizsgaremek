<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
    <body onload="Timer({{ $id }})">
    <h1></h1>
    <table>
        <tr>
            <th>Név</th>
            <th>Szavazat</th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
        </tr>
        @foreach ($szavazatok as $szavazat)
            <tr>
                @if ($szavazat['szavazat'] == $max)
                    <td style="color: green">{{ $szavazat['nev'] }}</td>
                @endif
                @if ($szavazat['szavazat'] == $min)
                    <td style="color: red">{{ $szavazat['nev'] }}</td>
                @endif
                @if ($szavazat['szavazat'] != $max && $szavazat['szavazat'] != $min)
                    <td>{{ $szavazat['nev'] }}</td>
                @endif
                <td>{{ $szavazat['szavazat'] }}</td>
                <td><div style="height: 20px; background-color: red; width: {{ $szavazat['szavazat'] }}px; border: 1px solid black;"></div></td>
                <td id="{{ $szavazat['id'] }}"></td>
                <td><button id="btn_{{ $szavazat['id'] }}" onclick="location.href='/szavazat-kuldes/{{ $szavazat['id'] }}'">Szavazás</button></td>
            </tr>
        @endforeach
    </table>
</body>
</html>

<script>
    function Timer(id)
    {
        document.getElementById("btn_" + id).disabled = true;
        document.getElementById(id).innerHTML = "10 sec";
        var count = 0;
        const intervalId = setInterval(() => {
            count++;
            document.getElementById(id).innerHTML = 10 - count + " sec";

            if (count === 10) {
                clearInterval(intervalId);
                document.getElementById(id).innerHTML = "";
                document.getElementById("btn_" + id).disabled = false;
            }
        }, 1000);
    }
</script>