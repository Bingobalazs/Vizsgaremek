<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration</title>
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">

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
    
    <form action="{{ route('registration.post') }}" method="POST">
        @csrf
        <input type="text" placeholder="Név:" name="name">
        <input type="email" placeholder="Email:" name="email">
        <input type="password" placeholder="Jelszó:" name="password">
        <button type="submit">Registration</button>
    </form>
    <a href="/login">Már van fiókom</a>
</body>
</html>