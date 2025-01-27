<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Etelek extends Model {
    protected $table = 'etelek';
    protected $primaryKey = 'id';
    public $timestamps = true;

    public function save(array $option=[]) {
        $this->ip = $_SERVER['REMOTE_ADDR'];
        $saved = parent::save($option);
    }
}
