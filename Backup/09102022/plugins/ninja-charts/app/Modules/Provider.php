<?php

namespace NinjaCharts\Modules;

use NinjaCharts\Modules\ChartJsCharts\ChartJsModule;
use NinjaCharts\Modules\GoogleCharts\GoogleChartModule;

class Provider
{

    public static function get($source)
    {
        if ($source === 'ninja_table') {
            return new NinjaTables\Module();
        } else if ($source === 'fluent_form') {
            return new FluentForms\Module();
        } else if ($source === 'manual') {
            return new ManualModule();
        }

        throw new \Exception(__("Couldn't find the provider.", 'ninja_cahrts'));
    }

    public static function renderEngine($render_engine)
    {
        if ($render_engine === 'chart_js') {
            return new ChartJsModule();
        } else if ($render_engine === 'google_chart'){
            return new GoogleChartModule();
        }

        throw new \Exception(__("Could not find the provider.", "ninja_cahrts"));
    }
}
