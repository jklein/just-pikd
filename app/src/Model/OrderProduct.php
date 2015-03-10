<?php

namespace Pikd\Model;

class OrderProduct {

    private $or_id;

    const TABLE = 'order_products';
    const SEQ = 'order_products_op_id_seq';

    public function __construct($db, $or_id) {
        $this->db = $db;
        $this->or_id = $or_id;
    }

    public function upsertProduct($data, $where) {
        $sql = 'SELECT op_qty from ' . self::TABLE . ' 
                WHERE op_or_id = :op_or_id 
                AND op_pr_sku = :op_pr_sku';

        $bind = [
            'op_or_id'  => $this->or_id,
            'op_pr_sku' => $data['op_pr_sku'],
        ];

        $result = $this->db->fetchOne($sql, $bind);

        if ($result === false) {
            return \Pikd\DB::insert($this->db, self::TABLE, $data, self::SEQ);
        } else {
            $data['op_qty'] += $result['op_qty'];
            return \Pikd\DB::update($this->db, self::TABLE, $data, $where);
        }
    }

    public function getAllProducts() {
        return \Pikd\DB::fetchAll($this->db, self::TABLE, ['op_or_id' => $this->or_id]);
    }
}