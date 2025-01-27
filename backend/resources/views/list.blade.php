<!DOCTYPE html>
<html>
<head>
    <title>Számítógép Lista</title>

    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body, html {
            height: 100%;
            margin: 0;
        }
        .centered-div {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .content {
            width: 80%;
            max-width: 800px;
        }
        th, td, table {
            text-align: center;
            border: 1px solid black;
            border-collapse: collapse;
        }
        
        .btn-delete {
            color: #fff;
            background-color: #dc3545;
            border-color: #dc3545;
            padding: 5px 10px;
            border-radius: 5px;
        }
        .btn-delete:hover {
            background-color: #c82333;
            border-color: #bd2130;
        }
    </style>
</head>
<body>
    <div class="centered-div">
        <div class="content">
            <h1 class="text-center">Számítógép Lista</h1>
            <table class="table table-bordered table-hover table">
                <thead class="thead-dark">
                    <tr>
                        <th>Gyártó</th>
                        <th>Típus</th>
                        <th>RAM</th>
                        <th>SSD</th>
                        <th>Monitor</th>
                        <th>Művelet</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($computers as $computer)
                        <tr>
                            <td>{{ $computer->gyarto }}</td>
                            <td>{{ $computer->tipus }}</td>
                            <td>{{ $computer->ram }} GB</td>
                            <td>{{ $computer->ssd }} GB</td>
                            <td>{{ $computer->monitor ? '✔' : '⨉' }}</td>
                            <td>
                                <a href="/szamitogep/torles/{{ $computer->id }}" class="btn-delete">Törlés</a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
            <br>
            <a href="/szamitogep/feltoltes" class="btn btn-primary">Új CSV Feltöltése</a>
        </div>
    </div>

    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>
