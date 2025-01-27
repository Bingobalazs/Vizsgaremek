<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Auto extends Model
{
    use HasFactory;
    protected $table = "Auto";
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'marka',
        'modell',
        'evjarat',
        'kilometer',
        'meghajtas',
        'allapot',
        'ar',
        'kep_url',
        'kontakt_info',
        'leiras',
        'user_id',
    ];
    public function autok()
    {
        return $this->hasMany(Auto::class, 'user_id');
    }

    protected $dates = ['created_at', 'updated_at'];
}