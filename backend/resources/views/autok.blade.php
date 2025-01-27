<!-- resources/views/autos/index.blade.php -->
<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eladó hazsnáltautók:</title>

    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">

    <style>
        .card {
            margin: 15px;
        }
    </style>
</head>
<body>
@include('partials.navbar')

<div class="container">
    <h1 class="mt-5">Autók Listája</h1>
    <div class="row">
        @foreach($autok as $auto)
            <div class="col-md-4">
                <div class="card">
                    <!-- amennyiben nem http link
                    <img src="{{ asset('storage/' . $auto->kep_url) }}" class="card-img-top" alt="{{ $auto->marka }} {{ $auto->modell }}">
                    -->

                    <img src="{{ $auto->kep_url }}" class="card-img-top" alt="{{ $auto->marka }} {{ $auto->modell }}">
                    <div class="card-body">
                        <h5 class="card-title">{{ $auto->marka }} {{ $auto->modell }}</h5>
                        <p class="card-text">Gyártási év: {{ $auto->evjarat }}</p>
                        <p class="card-text">Futásteljesítmény: {{ $auto->kilometer }} km</p>
                        <p class="card-text">Üzemanyag: {{ $auto->meghajtas }}</p>
                        <p class="card-text">Állapot: {{ $auto->allapot }}</p>
                        <p class="card-text">Ár: {{ $auto->ar }} HUF</p>
                        <p class="card-text">Kapcsolat: {{ $auto->kontakt_info }}</p>
                        <p class="card-text">Leírás: {{ $auto->leiras }}</p>
                    </div>
                </div>
            </div>
        @endforeach
    </div>
</div>

</body>
</html>