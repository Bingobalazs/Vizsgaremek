<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
</head>
<body>
    <p>Felhasználó: {{ $user['name'] }}</p>
    <p><a href="{{ route('kijelentkezes) }}">Kijelentkezés</a></p>
</body>
</html>