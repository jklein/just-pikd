<?php
/**
 * Use this file to convert images to jpegs
 * and store them on disk
 *
 */
$db_conn = get_connection("product");
$thread = $argv[1];
$image_sql = "SELECT i.image_id,
manufacturer_id,
CASE mime_type
    WHEN 'image/tga' THEN 'tga'
    WHEN 'image/tiff' THEN 'tif'
    WHEN 'image/jpeg' THEN 'jpg'
    WHEN 'image/png' THEN 'png'
END as extension, source
from images i
inner join products_images p on i.image_id = p.image_id
WHERE p.rank = 1 AND file_size IS NOT NULL AND source like 'http%'
AND alt_text IS NULL
AND i.image_id % 4 = $thread";
$image_data = pg_query($db_conn, $image_sql);

while ($row = pg_fetch_array($image_data)) {
    $raw_image = "/usr/share/nginx/html/images/" . $row['manufacturer_id'] . '/' . $row['image_id'] . '.' . $row['extension'];
    $crunched_image_dir = "/usr/share/nginx/html/crunched_images/" . $row['manufacturer_id'];
    if (!file_exists($crunched_image_dir)) {
      mkdir($crunched_image_dir);
    }
    if (!file_exists($raw_image)) {
        echo "Something has gone wrong - raw images lost? can't find $raw_image";
        exit(1);
    }
    $destination_image = "/usr/share/nginx/html/crunched_images/" . $row['manufacturer_id'] . '/' . $row['image_id'] . '.jpg';
    echo "convert $raw_image $destination_image\n";
    exec("convert $raw_image $destination_image", $output, $return);
    if ($return != 0) {
        var_dump($output);
    } else {
        //just a simple update to mark that we're done
        $sql = "update images set alt_text = 'Product Image'";
        $sql .= ' where image_id = ' . $row['image_id'];
        pg_query($db_conn, $sql);
    }
}

/**
 * get a connection to the local postgres instance
 *
 */
function get_connection ($dbname) {
    return pg_connect("host=localhost dbname=$dbname user=postgres password=justpikd");
}
