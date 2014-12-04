<?php
/**
 * Use this file to convert images to jpegs
 * and store them on disk
 *
 */
$db_conn = get_connection("product");
$thread = $argv[1];
$image_sql = "SELECT gtin,
manufacturer_id
from products p join base_products b on b.product_id = p.product_id where status = 'Active'";
$image_data = pg_query($db_conn, $image_sql);
$bads = array();
while ($row = pg_fetch_array($image_data)) {
    $source_stub = "/usr/share/nginx/html/data/images/" . $row['gtin'];
    $dest_stub = "/usr/share/nginx/html/images/" . $row['manufacturer_id'] . '/' . $row['gtin'];
    $crunched_image_dir = "/usr/share/nginx/html/images/" . $row['manufacturer_id'];
    if (!file_exists($crunched_image_dir)) {
      mkdir($crunched_image_dir);
    }
    $suffix = '_200x200.jpg';
    $success = rename($source_stub . $suffix, $dest_stub . $suffix);
    if (!$success) {
      $bads[] = $row['gtin'];
      echo "Failure to rename $source_stub to $dest_stub";
    }
    $suffix = '_600x600.jpg';
    rename($source_stub . $suffix, $dest_stub . $suffix);
    $success = rename($source_stub . $suffix, $dest_stub . $suffix);
}

/**
 * get a connection to the local postgres instance
 *
 */
function get_connection ($dbname) {
    return pg_connect("host=localhost dbname=$dbname user=postgres password=justpikd");
}
