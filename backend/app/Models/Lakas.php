<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lakas extends Model
{
    use HasFactory;

    protected $table = 'lakas';

    protected $fillable = [
        'e',
        'l',
    ];

    public $timestamps = false;
}


?>