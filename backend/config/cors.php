<?php
return [
    'paths' => ['api/*', '/PixelArtSpotlight/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['http://localhost:58053/', 'https://balgalazs.moriczcloud.hu', 'http://localhost:59964/'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
