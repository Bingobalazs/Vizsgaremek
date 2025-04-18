<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;


class User extends Authenticatable
{
    protected $table = "users";
    use HasApiTokens, HasFactory, Notifiable;


    protected $fillable = [
        'name', 'email', 'password', 'code', 'pfp_url',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function friends()
    {
        return $this->belongsToMany(User::class, 'friends', 'user_id', 'other_user_id')
            ->union(
                $this->belongsToMany(User::class, 'friends', 'other_user_id', 'user_id')
            );
    }
}
