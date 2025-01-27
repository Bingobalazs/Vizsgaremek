<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">

    <title>Reset Password</title>
</head>
<body>
<form method="POST" action="{{ route('password.update') }}">
    @csrf
    <input type="hidden" name="token" value="{{ $token }}">
    <label for="email">Email:</label>
    <input type="email" name="email" id="email" required>
    <label for="password">New Password:</label>
    <input type="password" name="password" id="password" required>
    <label for="password_confirmation">Confirm Password:</label>
    <input type="password" name="password_confirmation" id="password_confirmation" required>
    <button type="submit">Reset Password</button>
</form>
</body>
</html>