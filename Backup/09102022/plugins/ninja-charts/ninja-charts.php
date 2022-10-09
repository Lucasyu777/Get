<?php

/**
Plugin Name:    Ninja Charts
Description:    Ninja Charts - Best WP Charts Plugin for WordPress
Version:        3.1.2
Author:         WPManageNinja LLC
Author URI:     https://wpmanageninja.com/
Plugin URI:     https://wpmanageninja.com/ninja-charts
License:        GPL-2.0+
Text Domain:    ninja-charts
Domain Path:    /language
*/

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

define('NINJA_CHARTS_URL', plugin_dir_url(__FILE__));

$ninja_charts_info = get_file_data(__FILE__, array('Version' => 'Version'), false);
defined('NINJA_CHARTS_VERSION') or define('NINJA_CHARTS_VERSION', $ninja_charts_info['Version']);

require __DIR__.'/vendor/autoload.php';

call_user_func(function ($bootstrap) {
    $bootstrap(__FILE__);
}, require(__DIR__.'/boot/app.php'));
