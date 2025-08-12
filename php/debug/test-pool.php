<?php
// Force no caching for this test script
header('Cache-Control: no-cache, no-store, must-revalidate, max-age=0');
header('Pragma: no-cache');
header('Expires: Thu, 01 Jan 1970 00:00:00 GMT');
header('Content-Type: text/plain; charset=utf-8');

ini_set('memory_limit', 104);
ini_set('test_php_value', 'ini_set_value');

$pool_mode = getenv('PHP_POOL_MODE') ?: 'UNKNOWN';
$opcache_enabled = ini_get('opcache.enable') ? 'ENABLED' : 'DISABLED';
$validate_timestamps = ini_get('opcache.validate_timestamps') ? 'YES' : 'NO';
$memory_consumption = ini_get('opcache.memory_consumption');

// WordPress-specific settings from wordpress.conf
$memory_limit = ini_get('memory_limit');
$max_execution_time = ini_get('max_execution_time');
$max_input_vars = ini_get('max_input_vars');
$post_max_size = ini_get('post_max_size');
$upload_max_filesize = ini_get('upload_max_filesize');
$max_file_uploads = ini_get('max_file_uploads');
$session_gc_maxlifetime = ini_get('session.gc_maxlifetime');
$user_ini_filename = ini_get('user_ini.filename') ?: '.user.ini';
$user_ini = file_exists($user_ini_filename) ? $user_ini_filename : 'NOT FOUND';

echo "PHP-FPM Pool Test" . PHP_EOL;
echo "" . PHP_EOL;

echo "=== POOL CONFIGURATION ===" . PHP_EOL;
echo "Pool Mode: {$pool_mode}" . PHP_EOL;
echo "OPcache Status: {$opcache_enabled}" . PHP_EOL;
echo "Validate Timestamps: {$validate_timestamps}" . PHP_EOL;
echo "OPcache Memory: {$memory_consumption}M" . PHP_EOL;
echo "" . PHP_EOL;

echo "=== Non-standard variables ===" . PHP_EOL;
echo "test_php_admin_value: " . ini_get('test_php_admin_value') . PHP_EOL;
echo "test_php_value: " . ini_get('test_php_value') . PHP_EOL;
echo "" . PHP_EOL;
echo "PHP Version: " . phpversion() . PHP_EOL;
echo "" . PHP_EOL;

echo "=== WORDPRESS SETTINGS ===" . PHP_EOL;
echo "User INI File Name: {$user_ini_filename}" . PHP_EOL;
echo "User INI File: {$user_ini}" . PHP_EOL;
echo "User INI Cache TTL: " . ini_get('user_ini.cache_ttl') . " seconds" . PHP_EOL;

echo "Memory Limit: {$memory_limit}" . PHP_EOL;
echo "Max Execution Time: {$max_execution_time}s" . PHP_EOL;
echo "Max Input Vars: {$max_input_vars}" . PHP_EOL;
echo "Post Max Size: {$post_max_size}" . PHP_EOL;
echo "Upload Max Filesize: {$upload_max_filesize}" . PHP_EOL;
echo "Max File Uploads: {$max_file_uploads}" . PHP_EOL;
echo "Session GC Maxlifetime: {$session_gc_maxlifetime}s" . PHP_EOL;
echo "" . PHP_EOL;

echo "=== ENVIRONMENT VARIABLES ===" . PHP_EOL;
foreach($_SERVER as $key => $value) {
    if (strpos($key, 'PHP_') === 0) {
        echo "{$key}: {$value}" . PHP_EOL;
    }
}
echo "" . PHP_EOL;
echo "Timestamp: " . date('Y-m-d H:i:s') . PHP_EOL;

// if(file_exists($user_ini_filename)) {
//     echo PHP_EOL . "User INI File Content:" . PHP_EOL;
//     $ini_content = file_get_contents($user_ini_filename);
//     // Indent 
//     $ini_content = str_replace("\n", "\n    ", PHP_EOL . $ini_content);
//     echo $ini_content . PHP_EOL;
// }
