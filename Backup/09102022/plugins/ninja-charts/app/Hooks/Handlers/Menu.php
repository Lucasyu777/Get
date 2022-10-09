<?php

namespace NinjaCharts\Hooks\Handlers;

use NinjaCharts\App;
use NinjaCharts\Hooks\Handlers\Activation;

class Menu
{
    public function add()
    {
        $capability = apply_filters('ninja_charts_menu_capability', 'manage_options');
        add_menu_page(
            __('Ninja Charts', 'ninja-charts'),
            'Ninja Charts',
            $capability,
            'ninja-charts',
            array($this, 'renderApp'),
            $this->getIcon(),
            25
        );

        global $submenu;

        $submenu['ninja-charts']['chart-list'] = array(
            __('Ninja Charts', 'ninja-charts'),
            $capability,
            'admin.php?page=ninja-charts#/chart-list',
        );

        $submenu['ninja-charts']['add-chart'] = array(
            __('Add Chart', 'ninja-charts'),
            $capability,
            'admin.php?page=ninja-charts#/add-chart',
        );

        $submenu['ninja-charts']['support'] = array(
            __('Get help', 'ninja-charts'),
            $capability,
            'admin.php?page=ninja-charts#/support',
        );

        if (defined('NINJA_TABLES_VERSION')) {
            remove_menu_page('ninja-charts');
        }
    }

    public function renderApp()
    {
        $app = App::getInstance();
        $this->enqueueAssets();
        $app->view->render('admin.menu');
        $this->checkForDbMigration();
    }

    public function checkForDbMigration()
    {
        if (!get_site_option('_ninja_charts_installed_version')) {
            (new Activation)->handle();
        }
    }

    public function enqueueAssets()
    {
        $app = App::getInstance();

        $assets = $app['url.assets'];

        wp_enqueue_script(
            'ninja_charts_admin_app_boot',
            $assets . '/admin/js/boot.js',
            array('jquery')
        );

        wp_enqueue_style(
            'ninja_charts_admin_app',
            $assets . '/admin/css/ninja-charts-admin.css'
        );

        wp_localize_script('ninja_charts_admin_app_boot', 'NinjaChartsAdmin', array(
            'slug'       => $slug = $app->config->get('app.slug'),
            'nonce'      => wp_create_nonce($slug),
            'rest'       => $this->getRestInfo($app),
            'assets_url' => NINJA_CHARTS_URL . 'assets/',
        ));

        do_action('ninja_charts_loading_app');

        wp_enqueue_script(
            'ninja_charts_admin_app',
            $assets . 'admin/js/ninja-charts-admin-app.js',
            array('ninja_charts_admin_app_boot'),
            '1.0',
            true
        );

        wp_enqueue_script(
            'ninja_charts_admin_app_chart_label_format',
            $assets . 'common/js/chartjs-plugin-labels.js',
            array('ninja_charts_admin_app_boot'),
            '1.0',
            true
        );
        // Google Charts
        wp_enqueue_script(
            'ninja_charts_admin_app_google_charts',
            $assets . 'common/js/google-charts.js',
            array('ninja_charts_admin_app_boot'),
            '1.0',
            true
        );
    }

    public function getIcon()
    {
        $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 155.9 164.98"><defs><style>.cls-1{fill:#fff;}</style></defs><title>dashboard_icon</title><g id="Layer_2" data-name="Layer 2"><g id="Layer_1-2" data-name="Layer 1"><path class="cls-1" d="M153.46,160.11H138.84V70a2.43,2.43,0,0,0-2.43-2.43H112.05A2.43,2.43,0,0,0,109.61,70v90.13h-17V96.78a2.43,2.43,0,0,0-2.43-2.44H65.77a2.44,2.44,0,0,0-2.44,2.44v63.33h-17V109a2.43,2.43,0,0,0-2.43-2.44H19.49A2.44,2.44,0,0,0,17.05,109v51.15H2.44a2.44,2.44,0,1,0,0,4.87h151a2.44,2.44,0,1,0,0-4.87Z"/><path class="cls-1" d="M9.74,85.26h.15c.85,0,21.17-.74,48.07-10.33a188.9,188.9,0,0,0,43.95-22.38,178,178,0,0,0,36.93-34.09v5.91a4.88,4.88,0,0,0,9.75,0V4.87A4.87,4.87,0,0,0,143.11,0L123.62,2.47a4.87,4.87,0,0,0,1.21,9.67l7.33-.91C107.38,42.07,76.9,57.79,55,65.63,29.51,74.78,9.79,75.51,9.59,75.51a4.88,4.88,0,0,0,.15,9.75Z"/></g></g></svg>';
        return 'data:image/svg+xml;base64,' . base64_encode($svg);
    }

    protected function getRestInfo($app)
    {
        $ns = $app->config->get('app.rest_namespace');
        $v = $app->config->get('app.rest_version');

        return apply_filters('ninja_charts_rest_info', [
                'base_url'  => esc_url_raw(rest_url()),
                'url'       => rest_url($ns . '/' . $v),
                'nonce'     => wp_create_nonce('wp_rest'),
                'namespace' => $ns,
                'version'   => $v,
        ]);
    }

    public function loadAssetsNinjaTable()
    {
        $app = App::getInstance();
        $assets = $app['url.assets'];
        if (isset($_GET['page']) && defined('NINJA_TABLES_VERSION') && sanitize_text_field($_GET['page']) === 'ninja-charts') {
            wp_enqueue_script(
                'ninja_charts_extend_menu',
                $assets . '/admin/js/menu-active.js',
                array('ninja_charts_admin_app_boot'),
                '1.0',
                true
            );
        }
    }
}
