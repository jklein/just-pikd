<?php

namespace Pikd\Model;

class Order {

    const STATUS_BASKET = 'Basket';
    const STATUS_SHOPPING_LIST = 'Shopping List';
    const STATUS_PENDING_PICKUP = 'Pending Pickup';
    const STATUS_COMPLETE = 'Complete';
    const STATUS_CANCELLED = 'Cancelled';

    const TABLE = 'orders';
    const SEQ = 'orders_or_id_seq';

    public function __construct($dbconn, $cu_id, $so_id, $status) {
        $this->dbconn = $dbconn;
        $this->or_so_id = $so_id;
        $this->or_cu_id = $cu_id;
        $this->or_status = $status;

        $this->createOrGrabOrder();
    }

    private function createOrGrabOrder() {
        $sql = 'SELECT * from orders 
                where or_cu_id = :or_cu_id 
                and or_so_id = :or_so_id 
                and or_status = :or_status';

        $bind = [
            'or_cu_id' => $this->or_cu_id,
            'or_so_id' => $this->or_so_id,
            'or_status' => $this->or_status,
        ];
        $order = $this->dbconn->fetchOne($sql, $bind);

        if (empty($order)) {
            $this->or_id = $this->createOrder($bind);
        } else {
            $this->or_id = $order['or_id'];
        }
    }

    private function createOrder($data) {
        return \Pikd\DB::insert($this->dbconn, self::TABLE, $data, self::SEQ);
    }

    private function fetchOrder($data) {
        return \Pikd\DB::fetchAll($this->dbconn, self::TABLE, $data);
    }

    public function getBasketForCustomer() {

    }
}