<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Identicard extends Model
{

    protected $table = "identicard";
    use HasApiTokens;


    protected $fillable = [

    'name',
    'username',
    'email',
    'email_verified_at',
    'password',
    'remember_token',
    'created_at',
    'updated_at',
    'profile_picture',
    'cover_photo',
    'bio',
    'location',
    'birthday',
    'birthday_visibility',
    'pronouns',
    'relationship_status',
    'phone',
    'phone_visibility',
    'email_visibility',
    'messaging_apps',
    'website',
    'social_handles',
    'current_workplace',
    'job_title',
    'previous_workplaces',
    'education',
    'skills',
    'certifications',
    'languages',
    'portfolio_link',
    'hobbies',
    'theme_primary_color',
    'theme_accent_color',
    'theme_bg_color',
    'theme_text_color',
    'profile_visibility',

    ];
}
