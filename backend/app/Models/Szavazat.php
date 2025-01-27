<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Szavazat extends Model {
    protected $table = 'szavazas';
    protected $primaryKey = 'id';
    public $timestamps = true;
}
