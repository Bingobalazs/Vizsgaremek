<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">

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
    <form id="modify-form" method="POST" action="{{ route('modify.post') }}" enctype="multipart/form-data">
    <h1>Használtautó Hirdetés Módosítás</h1>
        @csrf
        <input type="number" hidden value="{{$auto->id}}" name="id">
        @foreach (['marka', 'modell', 'evjarat', 'kilometer', 'meghajtas', 'allapot', 'ar', 'kontakt_info', 'leiras'] as $field)
            <div style="margin-bottom: 10px;">
                <label for="{{ $field }}">{{ ucfirst(str_replace('_', ' ', $field)) }}:</label>

                <!-- Input mező -->
                @if($field === 'leiras')
                    <textarea id="{{ $field }}"
                              name="{{ $field }}"
                              rows="3"
                              disabled>{{ $auto->$field }}</textarea>
               
                @else
                    <input type="{{ $field === 'evjarat' || $field === 'kilometer' || $field === 'ar' ? 'number' : 'text' }}"
                           id="{{ $field }}"
                           name="{{ $field }}"
                           value="{{ $auto->$field }}"
                           disabled>
                @endif

                <!-- Szerkesztő gomb -->
                <button type="button" class="edit-btn" data-target="{{ $field }}">M</button>
            </div>
        @endforeach

        <button type="submit">Módosítás mentése</button>
    </form>
    </body>
    <script>
        // Gombok kezelése a mezők szerkeszthetőségéhez
        document.querySelectorAll('.edit-btn').forEach(button => {
            button.addEventListener('click', function () {
                const targetId = this.getAttribute('data-target');
                const input = document.getElementById(targetId);
                if (input) {
                    input.disabled = !input.disabled; // Átváltás: letiltva vagy engedélyezve
                }
            });
        });

        // Űrlap elküldésekor csak a módosított mezők hozzáadása a query stringhez

        /*
        document.getElementById('modify-form').addEventListener('submit', function (event) {
            event.preventDefault(); // Megakadályozzuk az alapértelmezett elküldést

            const params = new URLSearchParams();
            document.querySelectorAll('input, textarea').forEach(input => {
                if (!input.disabled && input.value.trim() !== '') {
                    params.append(input.name, input.value.trim());
                }
            });

            // Redirect az új URL-re a query stringgel
            const baseUrl = this.getAttribute('action');
            window.location.href = `${baseUrl}?${params.toString()}`;
        });

         */
    </script>
@endauth


@guest
    <script>
        window.location="{{route('index')}}";

    </script>
@endguest
</html>