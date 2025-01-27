<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">

    <title>Login</title>
</head>
<body>

    @if ($errors->any())
        @foreach ($errors->all() as $error)
            {{ $error }}
        @endforeach
    @endif

    @if (session()->has('error'))
        {{ session('error') }}
    @endif

    @if (session()->has('success'))
        {{ session('success') }}
    @endif
    
    <form action="{{ route('login.post') }}" method="POST">
        @csrf
        <input type="email" placeholder="Email:" name="email">
        <input type="password" placeholder="Jelszó:" name="password">
        <button type="submit">Login</button>
    </form>
    <a href="/registration">Még nincs fiókom</a>
    <a href="{{route('password.request')}}">Elfelejtett jelszó</a>
</body>
</html>