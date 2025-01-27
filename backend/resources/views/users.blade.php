<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kit ismerhetek?</title>
</head>
<body>
    @include('partials.navbar')

    @foreach($users as $user)
        {{ $user->name }} 
        <form action="{{ route('jeloles', ['id' => $user->id]) }}" method="POST" enctype="multipart/form-data">
            @csrf
            <button class="btn btn-primary" type="submit">Ismerősnek jelölöm</button>
        </form>
        <hr>
    @endforeach
</body>
</html>