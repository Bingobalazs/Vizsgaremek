<!DOCTYPE html>
<style>
    table, th, td
    {
        border: 2px solid black;
        border-collapse: collapse;
    }

    td
    {
        padding-top: 3px;
        padding-right: 5px;
        padding-left: 5px;
    }

    .ar
    {
        text-align: right;
    }
    .leiras
    {
        color: grey;
        font-style: italic;
        font-size: large;
    }

    .tel
    {
        color: grey;
        font-size: large;
    }
</style>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <title>{{ $item->marka }} {{ $item->modell }}</title>
</head>
@auth
<body>
@include('partials.navbar')
    <div class="container">
        <div class="row">
            <div class="col-md-4"></div>
            <div class="col-md-4">
                <img class="w-100" src="{{ asset( $item->kep_url) }}">

                <h2>{{ $item->marka }} {{ $item->modell }}</h2>
                <p>{{ $item->user_name }}</p>
                <p style="color: grey">
                @if ($item->created_at instanceof \Carbon\Carbon)
                    {{ $item->created_at->format('Y. m . d.') }}
                @else
                    {{ \Carbon\Carbon::parse($item->created_at)->format('Y. m. d.') }}
                @endif
                </p>
                <!--<button class="btn btn-primary" onclick="window.location.href='{{ url('/like/' . $i->id) }}';">LIKE</button>-->
                <p><span class="leiras">{{ $item->leiras }}</span><br><span class="tel">{{ $item->kontakt_info }}</span></p>
                <h3 class="ar">{{ $item->ar }} Ft</h3>
            </div>
            <div class="col-md-4"></div>
        </div>
        <div class="row">
            @forelse ($comments as $comment)
                @if($comment->user_id != auth()->user()->id)
                    <p>
                        <span style="color: grey; font-style: italic">
                            @if ($comment->created_at instanceof \Carbon\Carbon)
                                {{ $comment->created_at->diffForHumans() }}
                            @else
                                {{ \Carbon\Carbon::parse($comment->created_at)->diffForHumans() }}
                            @endif
                        </span>
                        <br>
                        <strong>{{ $comment->user_name }}</strong>: 
                        {{ $comment->comment }}
                    </p>
                @else
                    <p style="text-align: right">
                        <span style="color: grey; font-style: italic">
                            @if ($comment->created_at instanceof \Carbon\Carbon)
                                {{ $comment->created_at->diffForHumans() }}
                            @else
                                {{ \Carbon\Carbon::parse($comment->created_at)->diffForHumans() }}
                            @endif
                        </span>
                        <br>
                        {{ $comment->comment }}
                    </p>
                @endif
            @empty
                <p style="color:grey">Nincsenek kommentek.</p>
            @endforelse
        </div>
        <div class="row">
            <form action="{{ route('comment', ['id' => $car->id]) }}" method="POST">
                @csrf
                <div class="form-group mb-3">
                    <label for="exampleFormControlTextarea1">Komment:</label>
                    <textarea name="comment" class="form-control" id="exampleFormControlTextarea1" rows="3"></textarea>
                </div>
                <button type="submit" class="btn btn-secondary">Beküldés</button>
            </form>
            <div style="height: 200px"></div>
        </div>
    </div>
</body>
@endauth
@guest
<script>
    window.location="{{route('index')}}";
</script>
@endguest
</html>