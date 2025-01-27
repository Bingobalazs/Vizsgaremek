<!DOCTYPE html>
<html>
<head>
    <title>CSV Feltöltés</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1 class="text-center mb-4">CSV Feltöltés</h1>
        <div class="card">
            <div class="card-body">
                <form action="/szamitogep/beir" method="POST">
                    @csrf
                    <div class="form-group">
                        <label for="csv_data">CSV Adatok:</label>
                        <textarea name="csv_data" id="csv_data" rows="10" class="form-control" required>gyarto;tipus;ram;ssd;monitor</textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Feltöltés</button>
                </form>
                
                @if ($errors->any())
                    <div class="alert alert-danger mt-4">
                        <strong>Hiba:</strong>
                        <ul class="mb-0">
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
