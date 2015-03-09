<?php
/*
 * This file is part of the DebugBar package.
 *
 * (c) 2013 Maxime Bouroumeau-Fuseau
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
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
            $data[] = "Function: " . ucfirst($entry['function']) . 
                        ', Duration: ' . round($entry['duration'], 4) . ' seconds' . 
                        ', Bind Values: ' . json_encode($entry['bind_values']);
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