<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mikuláscsomag</title>
</head>
<body>
    <form action="/mikulas-kuldes" method="GET">
        <input id="nev" name="nev" type="text" placeholder="Név">
        <p><input onclick="Szamol()" id="c" name="c" type="checkbox">Csoki 350Ft</p>
        <p><input onclick="Szamol() id="r" name="r" type="checkbox">Ropi 300Ft</p>
        <p><input onclick="Szamol() id="s" name="s" type="checkbox">Szotyi 300Ft</p>
        <p><input onclick="Szamol() id="k" name="k" type="checkbox">Kóla 450Ft</p>
        <p><input onclick="Szamol() id="g" name="g" type="checkbox">Gumicukor 450Ft</p>
        <button id="btn" type="submit">Értesítem a mikulást</button><p>0Ft</p>
    </form>
</body>
</html>
<script>
    function Szamol()
    {
        
    }
</script>