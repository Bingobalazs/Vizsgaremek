<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Image extends Model
{
    protected $table = 'webaruhaz';

    protected $fillable = ['title', 'path', 'price', 'new_price', 'text'];
}
