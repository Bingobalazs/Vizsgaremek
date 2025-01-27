<!DOCTYPE html>
<style>
    .clk
    {
        cursor: pointer;
        margin-bottom: 20px;
    }

    .container
    {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
    }

    .box
    {
        flex: 1 1 calc(25% - 10px);
        max-width: calc(25% - 10px);
        padding: 20px;
        background-color: lightblue;
        border: 1px solid blue;
        text-align: center;
        box-sizing: border-box;
    }
    .date
    {
        color: grey;
        font-style: italic;
        font-size: small;
    }
</style>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Hazsnáltauto</title>
</head>
<body>
    @auth
    @include('partials.navbar')
        <div class="container">
            <div class="col-md-2"></div>
            <div class="col-md-8">
            @foreach ($data as $i)
                <div class="card w-100" onclick="window.location.href='{{ url('/cars/' . $i->id) }}';">
                    <img src="{{ asset( $i->kep_url) }}" class="card-img-top" alt="...">
                    <div class="card-body">
                        <h5 class="card-title">{{ $i->marka }} {{ $i->modell }}</h5>
                        <p class="card-text">
                            @if ($i->created_at instanceof \Carbon\Carbon)
                                {{ $i->created_at->format('Y. m . d.') }}
                            @else
                                {{ \Carbon\Carbon::parse($i->created_at)->format('Y. m. d.') }}
                            @endif
                        </p>
                    </div>
                </div>
            @endforeach
            </div>
            <div class="col-md-2"></div>
        </div>
    @endauth

    @guest
        <h1 style="color: gray">Apádat Puzsi</h1>
        <h2>Jelentkezz be</h2>
        @include('login')




        <form action="{{ route('registration') }}" method="GET">
            @csrf
            <button type="submit">Regisztrálok</button>
        </form>
    @endguest
</body>
</html>