<?php
/**
 * Use this file to download images from itemmaster data
 * and store them on disk
 *
 * I used this after loading the data into images but with it still containing raw URLs
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
WHERE p.rank = 1 AND file_size IS NULL AND source like 'http%'
AND i.image_id % 4 = $thread";
$image_data = pg_query($db_conn, $image_sql);

while ($row = pg_fetch_array($image_data)) {
    if (!file_exists("/usr/share/nginx/html/images/" . $row['manufacturer_id'])){
        mkdir("/usr/share/nginx/html/images/" . $row['manufacturer_id']);
    }
    $destination_file = "/usr/share/nginx/html/images/" . $row['manufacturer_id'] . '/' . $row['image_id'] . '.' . $row['extension'];
    $retry_count = 0;
    while ($retry_count < 2) {
        echo "curling to " . $row['source'];
        $success = file_put_contents($destination_file, file_get_contents($row['source']));
        if ($success) {
            $filesize = filesize($destination_file);
            $sql = 'update images set file_size = ' . $filesize;
            $sql .= ' where image_id = ' . $row['image_id'];
            pg_query($db_conn, $sql);
            break;
        }
        echo "failed to download " . $row['source'] . ", retry count of $retry_count";
        $retry_count++;
    }
}

/**
 * get a connection to the local postgres instance
 *
 */
function get_connection ($dbname) {
    return pg_connect("host=localhost dbname=$dbname user=postgres password=justpikd");
}
