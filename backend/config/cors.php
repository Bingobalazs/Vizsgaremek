<?php
return [
    'paths' => ['api/*', '/PixelArtSpotlight/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost',
        'https://localhost', 
        'http://localhost:1011',
        'https://localhost:1011', 
        'https://balgalazs.moriczcloud.hu',
        'https://kovacscsabi.moriczcloud.hu',
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
