<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">


    <title>Használtautó Hirdetés Feltöltése</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
            
            display: flex;
            align-content: center;
            justify-content: center;
        }
        label {
            display: block;
            margin: 10px 0 5px;
        }
        input, select, textarea {
            width: 100%;
            padding: 8px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            padding: 10px 15px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #007FFF;
        }
        form{
            border: 1px solid #ccc;
            border-radius: 5px;

            max-width: 600px;
            padding: 20px;
            width: 100%; /* Ensure the form doesn't exceed the screen width */
            background-color: white; /* Optional: Set a background for the form */
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Optional: Add a shadow for a nice effect */
        }
    </style>
</head>
@auth
<body>
@include('partials.navbar')
<form action="{{ route('add.post') }}" method="POST" enctype="multipart/form-data">
<h1>Használtautó Hirdetés Feltöltése</h1>

@csrf
    <label for="marka">Márka:</label>
    <input type="text" id="marka" name="marka" required>

    <label for="modell">Típus:</label>
    <input type="text" id="modell" name="modell" required>

    <label for="evjarat">Gyártási év:</label>
    <input type="number" id="evjarat" name="evjarat" min="1886" max="2050" required>

    <label for="kilometer">Futásteljesítmény (km):</label>
    <input type="number" id="kilometer" name="kilometer" required>

    <label for="meghajtas">Üzemanyag típusa:</label>
    <select id="meghajtas" name="meghajtas" required>
        <option value="Benzin">Benzin</option>
        <option value="Dízel">Dízel</option>
        <option value="Elektromos">Elektromos</option>
        <option value="Hibrid">Hibrid</option>
    </select>

    <label for="allapot">Állapot:</label>
    <select id="allapot" name="allapot" required>
        <option value="Újszerű">Újszerű</option>
        <option value="Jó">Jó</option>
        <option value="Használt">Használt</option>
        <option value="Sérült">Sérült</option>
    </select>

    <label for="ar">Ár (HUF):</label>
    <input type="text" id="ar" name="ar" required>

    <label for="kep_url">Kép URL (JSON formátumban):</label>
    <input id="kep_url" name="kep_url" type="file" ></input>

    <label for="kontakt_info">Hirdető elérhetősége:</label>
    <input type="text" id="kontakt_info" name="kontakt_info" required>

    <label for="leiras">Leírás:</label>
    <textarea id="leiras" name="leiras" rows="6" required></textarea>

    <button type="submit">Hirdetés Feltöltése</button>
</form>
</body>
@endauth


@guest
<script>
    window.location="{{route('index')}}";
</script>
@endguest
</html>