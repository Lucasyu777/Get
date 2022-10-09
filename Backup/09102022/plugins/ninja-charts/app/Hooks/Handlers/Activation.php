<?php

namespace NinjaCharts\Hooks\Handlers;

use NinjaCharts\Database\DBSeeder;
use NinjaCharts\Database\DBMigrator;

class Activation
{
    public function handle($network_wide = false)
    {
        DBMigrator::run($network_wide);
        DBSeeder::run();
        update_option('_ninja_charts_installed_version', NINJA_CHARTS_VERSION, 'no');
    }
}
