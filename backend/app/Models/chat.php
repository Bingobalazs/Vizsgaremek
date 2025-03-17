<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Chat extends Model
{
    use HasFactory;

    protected $table = "chat";
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'from_id',
        'to_id',
        'chat',
    ];

    protected $dates = ['created_at', 'updated_at'];
}