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
class SQLQueries extends \DebugBar\DataCollector\DataCollector implements \DebugBar\DataCollector\Renderable
{
    protected $name;
    protected $data;

    /**
     * @param array  $data
     * @param string $name
     */
    public function __construct(array $data, $name = 'SQLQueries')
    {
        $this->name = $name;
        $this->data = $data;
    }

    public function collect()
    {
        $data = [];
        foreach ($this->data as $entry) {
            if ($entry['function'] === 'perform') {
                $data[] = $entry['statement'] . 
                        ' completed in ' . round($entry['duration'], 4) . ' seconds' . 
                        ' with bind values: ' . json_encode($entry['bind_values']);
            }
            
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
                "widget" => "PhpDebugBar.Widgets.ListWidget",
                "map" => "$name",
                "default" => "{}"
            )
        );
    }
}