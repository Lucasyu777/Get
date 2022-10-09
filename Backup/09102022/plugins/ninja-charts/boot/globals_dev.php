<?php

if (!function_exists('ninjaChartsEqL')) {
    function ninjaChartsEqL()
    {
        defined('SAVEQUERIES') || define('SAVEQUERIES', true);
    }
}

if (!function_exists('ninjaChartsGql')) {
    function ninjaChartsGql()
    {
        $result = [];

        foreach ((array)$GLOBALS['wpdb']->queries as $key => $query) {
            $result[++$key] = array_combine([
                'query', 'execution_time'
            ], array_slice($query, 0, 2));
        }

        return $result;
    }
}
