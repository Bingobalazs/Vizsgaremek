<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Regisztráció</title>
</head>
<body>
    <h1>Regisztráció</h1>

    @if ($errors->any())
        <div style="color: red;">
            <ul>
                @foreach (errors->$all() as $error)
                    <li>{{ error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('regisztralas') }}" method="post">
        @csrf
        <label>Név</label>
        <input type="text" maxlength=255 name="name">
        <label>E-mail</label>
        <input type="email" maxlength=255 name="email">
        <label>Jelszó</label>
        <input type="password" name="password">
        <br><br>
        <input type="submit" value="Regisztráció">
    </form>
</body>
</html>