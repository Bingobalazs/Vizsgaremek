<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $user->name }} adatai</title>
</head>
<body>
    @include('partials.navbar')

    <form method="POST" action="{{ route('modifyprofile') }}" enctype="multipart/form-data">
        @csrf
        <p>Név<input type="text" name="name" value="{{ $user->name }}"></p>
        <p>Email<input type="email" name="email" value="{{ $user->email }}"></p>
        <p>Jelszó<input type="password" name="password" placeholder="Jelszó megváltoztatása"></p>

        @if($user->public == 1)
            <p>Public <input type="radio" name="public" value="1" checked></p>
            <p>Privát <input type="radio" name="public" value="0"></p>
        @else
            <p>Public <input type="radio" name="public" value="1"></p>
            <p>Privát <input type="radio" name="public" value="0" checked></p>
        @endif

        <button class="btn btn-outline-secondary" type="submit">Módosítás</button>
    </form>
</body>
</html>