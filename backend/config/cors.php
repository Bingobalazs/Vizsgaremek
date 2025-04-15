<?php
return [
    'paths' => ['api/*', 'uploads/*', 'sanctum/csrf-cookie', 'public/uploads/*', '*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://balgalazs.moriczcloud.hu',
        'http://localhost:1000'
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
