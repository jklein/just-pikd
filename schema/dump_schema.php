<?php
/**
 * Use this file to dump the schema of all databases and commit to Git
 * Run from within vagrant ssh:
 * php -f /usr/share/nginx/html/schema/dump_schema.php
 */

putenv("PGPASSWORD=justpikd");

$output_folder = '/usr/share/nginx/html/schema';

$databases = [
    'product',
    'customer',
    'hr',
];

// Dump all databases
foreach ($databases as $database) {
    $command = "/usr/bin/pg_dump -h localhost -U postgres -d $database --schema-only > $output_folder/$database.sql";
    exec($command);
}
