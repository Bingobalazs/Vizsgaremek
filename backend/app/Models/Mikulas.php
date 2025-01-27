<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mikulas extends Model {
    protected $table = 'csomag';
    protected $primaryKey = 'nev';
    public $timestamps = false;
}

?>