<?php
/**
 * Use this file to convert images to jpegs
 * and store them on disk
 *
 */
$db_conn = get_connection("product");
$image_sql = "SELECT gtin,
manufacturer_id
from products p join base_products b on b.product_id = p.product_id where status = 'Active'";
$image_data = pg_query($db_conn, $image_sql);
while ($row = pg_fetch_array($image_data)) {
    $dest_stub = "/usr/share/nginx/html/images/" . $row['manufacturer_id'] . '/' . $row['gtin'];
    $suffix = '_200x200.jpg';
    if (!file_exists($dest_stub . $suffix)) {
      echo "not found: $dest_stub" . $suffix;
    }
    $suffix = '_600x600.jpg';
    if (!file_exists($dest_stub . $suffix)) {
      echo "not found: $dest_stub" . $suffix;
    }
}

/**
 * get a connection to the local postgres instance
 *
 */
function get_connection ($dbname) {
    return pg_connect("host=localhost dbname=$dbname user=postgres password=justpikd");
}
