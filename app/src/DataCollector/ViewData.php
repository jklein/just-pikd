<?php
/**
 * A debugbar DataCollector for SQL Queries
 *
 * @author      Jonathan Klein
 * @copyright   (c) 2015 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */

namespace Pikd\DataCollector;

/**
 * Collects array data
 */
class ViewData extends \DebugBar\DataCollector\DataCollector implements \DebugBar\DataCollector\Renderable
{
    protected $name;
    protected $data;

    /**
     * @param array  $data
     * @param string $name
     */
    public function __construct(array $data, $name = 'ViewData')
    {
        $this->name = $name;
        $this->data = $data;
    }

    public function collect()
    {
        $data = [];
        foreach ($this->data as $k => $v) {
            if (!is_string($v)) {
                $v = $this->getDataFormatter()->formatVar($v);
            }
            $data[$k] = $v;
        }
        return $data;
    }

    public function getName()
    {
        return $this->name;
    }

    public function getWidgets()
    {
        $name = $this->getName();
        return array(
            "$name" => array(
                "icon" => "gear",
                "widget" => "PhpDebugBar.Widgets.VariableListWidget",
                "map" => "$name",
                "default" => "{}"
            )
        );
    }
}