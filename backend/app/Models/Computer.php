<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Computer extends Model
{
    use HasFactory;

    // Az oszlopok, amelyek kitölthetők tömeges hozzárendeléssel
    protected $fillable = [
        'gyarto', 'tipus', 'ram', 'ssd', 'monitor',
    ];
}
