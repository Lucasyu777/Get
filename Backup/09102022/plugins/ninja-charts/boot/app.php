<?php

use NinjaCharts\Framework\Foundation\Application;
use NinjaCharts\Hooks\Handlers\Activation;
use NinjaCharts\Hooks\Handlers\Deactivation;

return function ($file) {
    register_activation_hook($file, function () {
        (new Activation)->handle();
    });

    register_deactivation_hook($file, function () {
        (new Deactivation)->handle();
    });

    add_action('plugins_loaded', function () use ($file) {
        do_action('ninjaCharts_loaded', new Application($file));
    });
};
