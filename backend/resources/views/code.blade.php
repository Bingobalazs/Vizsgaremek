<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">

    <title>Cím</title>
</head>
<body>
    <p>Küldtünk egy emailt a(z) {{ $data['email'] }} címre. Írja be az ellenőrző kódot!</p>
    <form action="{{ route('registration.code') }}" method="POST">
        @csrf
        <input type="hidden" name="data" value="{{ json_encode($data) }}">
        <input type="text" name="code2">
        <button type="submit">Submit</button>
    </form>
</body>
</html>