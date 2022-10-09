<?php

/**
 * @var $app NinjaCharts\Framework\Foundation\Application
 */
/*
 * charts Route
*/
$app->group(function ($app) {
    $app->get('charts', 'ChartController@index');
    $app->post('charts', 'ChartController@store');
    $app->get('charts/{id}', 'ChartController@find')->int('id');
    $app->post('charts/{id}/duplicate', 'ChartController@duplicate')->int('id');
    $app->post('process', 'ChartController@processData');
    $app->post('remove', 'ChartController@destroy');
})->withPolicy('ChartPolicy');

/*
 * sources Route
 */
$app->group(function ($app) {
    $app->get('/', 'SourceController@index');
    $app->get('/{sourceId}', 'SourceController@find')->int('sourceId');
})->prefix('sources')->withPolicy('SourcePolicy');

$app->get('ninjatable-data-provider/{tableId}', 'SourceController@sourceName')->int('tableId');