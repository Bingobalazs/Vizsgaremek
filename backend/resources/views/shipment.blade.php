@if (!is_numeric($id))
    <h1>Valami nem oké</h1>
@elseif (strlen((string) $id) != 10)
    <h1>Valami nem oké</h1>
@elseif (preg_match('/[13579]/', $id))
    <h1>Érvénytelem ID</h1>
@else
    <h1>Minden oké</h1>
@endif