<!DOCTYPE html>
<style>
    .house
    {
        background-color: grey;
        border: 1px solid black;
    }
    .window
    {
        background-color: white;
        height: 20px;
        border: 1px solid black;
    }
    .door
    {
        bottom: 0;
        width: 50%;
        margin: 0 auto;
        display: block;
    }
    .ground
    {
        background-color: lightgrey;
        height: 200px;
    }
    .sky
    {
        background-color: lightblue;
        border-right: 5px solid grey;
    }
</style>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lakás</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">    </head>
<body>
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-6 sky">
                <div class="row">
                    <div class="col-md-4"></div>
                    <div class="col-md-4">
                        <div class="house w-100 p-2 mt-2">
                            <div class="row mb-5">
                                <div class="col-md-3"><div id="e5l1" class="window w-100"></div></div>
                                <div class="col-md-6"></div>
                                <div class="col-md-3"><div id="e5l4" class="window w-100"></div></div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-3"><div id="e4l1" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e4l2" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e4l3" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e4l4" class="window w-100"></div></div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-3"><div id="e3l1" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e3l2" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e3l3" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e3l4" class="window w-100"></div></div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-3"><div id="e2l1" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e2l2" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e2l3" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e2l4" class="window w-100"></div></div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-3"><div id="e1l1" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e1l2" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e1l3" class="window w-100"></div></div>
                                <div class="col-md-3"><div id="e1l4" class="window w-100"></div></div>
                            </div>
                            <div class="row">
                                <div class="col-md-3"><div id="e0l1" class="window w-100"></div></div>
                                <div class="col-md-6">
                                    <img class="door" src="https://pngfre.com/wp-content/uploads/door-62.png">
                                </div>
                                <div class="col-md-3"><div id="e0l4" class="window w-100"></div></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4"></div>
                </div>
                <div class="row ground"></div>
            </div>
            <div class="col-md-6"> 
                <form action="{{ route('store-lakas') }}" method="POST">
                    @csrf
                    <label>Emelet</label>
                    <select name="e" id="emelet" class="mb-5" onChange="Main()">
                        <option value="e0">Földszint</option>
                        <option value="e1">1. emelet</option>
                        <option value="e2">2. emelet</option>
                        <option value="e3">3. emelet</option>
                        <option value="e4">4. emelet</option>
                        <option value="e5">5. emelet</option>
                    </select>

                    <br>

                    <label>Lakás</label>
                    <select name="l" id="lakas" class="mb-5">
                        <option value="l1">1.</option>
                        <option value="l2" disabled>2.</option>
                        <option value="l3" disabled>3.</option>
                        <option value="l4">4.</option>
                    </select>

                    <br>

                    <button class="btn btn-secondary mb-2" onClick="Foglalas()">Foglalás</button>
                </form>
                <button class="btn btn-secondary" onClick="Torles()">Törlés</button>
            </div>
        </div>
    </div>
</body>
</html>
<script>
    function Main()
    {
        var emelet = document.getElementById('emelet').value;
        var lakas = document.getElementById('lakas');

        if (emelet == "e0" || emelet == "e5")
        {
            lakas.options[1].disabled = true;
            lakas.options[2].disabled = true;
        }
        else
        {
            lakas.options[1].disabled = false;
            lakas.options[2].disabled = false;
        }
    }

    function Foglalas()
    {
        var kivalasztott = document.getElementById(Kivalaszt());
        kivalasztott.style.background = "yellow";
    }

    function Torles()
    {
        var kivalasztott = document.getElementById(Kivalaszt());
        kivalasztott.style.background = "white";


        var sor = document.getElementById('emelet').value;
        var oszlop = document.getElementById('lakas').value;
        fetch(`/torles/${sor}/${oszlop}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        }).then(response => {
            if (response.ok) {
                const elem = document.getElementById(`${sor}${oszlop}`);
                if (elem) {
                    elem.style.backgroundColor = '';
                }
            } else {
            }
        });
    }

    function Kivalaszt()
    {
        var emelet = document.getElementById('emelet').value;
        var lakas = document.getElementById('lakas').value;

        return emelet + lakas;
    }

    const koordinatak = @json($koordinatak);

    koordinatak.forEach(koord => {
        const elemId = `${koord.e}${koord.l}`;
        const elem = document.getElementById(elemId);
        if (elem) {
            elem.style.backgroundColor = 'yellow';
        }
    });
</script>