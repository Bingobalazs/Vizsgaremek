
<!DOCTYPE html>
<style>
    .input 
    {
        position: absolute;
        left: 500px
    }
</style>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <title>Hirdetéseim</title>

    <script>
        function toggleSelectAll(source) {
            const checkboxes = document.querySelectorAll('input[name="ids[]"]');
            checkboxes.forEach(checkbox => checkbox.checked = source.checked);
        }

        document.addEventListener('DOMContentLoaded', () => {
            const selectAllCheckbox = document.getElementById('select-all');
            const itemCheckboxes = document.querySelectorAll('input[name="ids[]"]');

            itemCheckboxes.forEach(checkbox => {
                checkbox.addEventListener('change', () => {
                    selectAllCheckbox.checked = Array.from(itemCheckboxes).every(cb => cb.checked);
                });
            });
        });
    </script>
</head>
@auth
<body>
    @include('partials.navbar')
    <div class="container">
        <form action="{{ route('own.delete') }}" method="POST">
            @csrf
            @method('DELETE')

            <table class="table">
                <tr>
                    <th></th>
                    <th style="text-align: right">Összes kiválasztása: </th>
                    <th><input class="form-check-input" type="checkbox" id="select-all" onclick="toggleSelectAll(this)"></th>
                    <th></th>
                </tr>
                @foreach ($data as $item)
                    <tr>
                        <td>{{ $item->marka }} {{ $item->modell }}</td>
                        <td>{{ $item->created_at }}</td>
                        <td><input class="form-check-input" type="checkbox" name="ids[]" value="{{ $item->id }}"></td>
                        <td><button class="btn btn-secondary" type="button" onclick="window.location.href='{{ route('modify', ['id' =>  $item->id]) }}';">Szerkesztés</button></td>
                    </tr>
                @endforeach
            </table>
            <button class="btn btn-danger" type="submit">Törlés</button>
        </form>

        @if (session('success'))
            <p style="color: green;">{{ session('success') }}</p>
        @endif

        @if (session('error'))
            <p style="color: red;">{{ session('error') }}</p>
        @endif
    </div>
</body>
</html>
@endauth


@guest
    <script>
        window.location="{{route('index')}}";
    </script>
@endguest