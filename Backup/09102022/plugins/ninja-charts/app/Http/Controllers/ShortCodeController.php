<?php

namespace NinjaCharts\Http\Controllers;

use NinjaCharts\App;
use NinjaCharts\Traits\ChartDesignHelper;
use NinjaCharts\Models\NinjaCharts;
use NinjaCharts\Framework\Support\Arr;
use NinjaCharts\Traits\ChartOption;
use NinjaCharts\Modules\Provider;

class ShortCodeController extends Controller
{
    use ChartDesignHelper, ChartOption;

    public function makeShortCode($atts = [], $content = null, $tag = '')
    {
        // normalize attribute keys, lowercase
        $atts = array_change_key_case((array)$atts, CASE_LOWER);
        // override default attributes with user attributes
        $wporg_atts = shortcode_atts([
            'id' => null,
        ], $atts, $tag);

        $id = Arr::get($wporg_atts, 'id');
        $ninjaCharts = NinjaCharts::find($id);
        if ($ninjaCharts) {
            $chart_data = Provider::get($ninjaCharts->data_source)->renderChart($ninjaCharts);
            return $this->renderView($ninjaCharts, $chart_data);
        } else {
            return __("Invalid ShortCode...!", 'ninja_charts');
        }
    }

    public function ninjaChartsShortCode()
    {
        add_shortcode('ninja_charts', [$this, 'makeShortCode']);
    }

    public function renderView($ninjaCharts, $chart_data)
    {
        $app = App::getInstance();
        $ninjaCharts = $this->undefinedChartOptionsAppend($ninjaCharts);
        $ninjaCharts['chart_data'] = $chart_data;
        $options = json_decode(Arr::get($ninjaCharts, 'options'), true);
        $uniqid =  '_' . rand() . '_' . Arr::get($ninjaCharts, 'id');
        $chart_keys = [
            "uniqid"        => $uniqid,
            "id"            => Arr::get($ninjaCharts, 'id')
        ];
        self::addInlineVars($ninjaCharts, 'ninja_charts_instance');
        if ($ninjaCharts->render_engine === 'chart_js') {
            self::chartJsAssets();
            do_action('ninja_charts_shortcode_assets_loaded');
            return $app->view->make('public.chart_js', compact('options', 'chart_keys', 'chart_data'));
        } else if ($ninjaCharts->render_engine === 'google_charts'){
            self::googleChartsAssets();
            do_action('ninja_charts_shortcode_assets_loaded');
            return $app->view->make('public.google_charts', compact('options', 'chart_keys', 'chart_data'));
        }
    }

    private static function addInlineVars($data, $chart_instance_name)
    {
        add_action('wp_footer', function () use ($data, $chart_instance_name) {
            $name = $chart_instance_name . '_' . Arr::get($data, 'id');
        ?>
            <script type="text/javascript">
                window['<?php echo $name; ?>'] = <?php echo $data; ?>
            </script>
        <?php
        });
    }

    private static function chartJsAssets()
    {
        wp_enqueue_script(
            'chartjs',
            NINJA_CHARTS_URL . 'assets/public/js/library/chart.min.js',
            array('jquery'),
            '2.9.3',
            true
        );

        wp_enqueue_script(
            'chartjs_plugin_labels',
            NINJA_CHARTS_URL . 'assets/common/js/chartjs-plugin-labels.js',
            array('chartjs'),
            '1.0.0',
            true
        );
        wp_enqueue_script(
            'chart_js_chart_render_js',
            NINJA_CHARTS_URL . 'assets/public/js/render.js',
            array('chartjs'),
            '1.0.0',
            true
        );
    }

    private static function googleChartsAssets()
    {
        wp_enqueue_script(
            'googlechart',
            NINJA_CHARTS_URL . 'assets/common/js/google-charts.js',
            array('jquery'),
            '1.0.0',
            true
        );
        wp_enqueue_script(
            'google_chart_render_js',
            NINJA_CHARTS_URL . 'assets/public/js/google-chart-render.js',
            array('googlechart'),
            '1.0.0',
            true
        );
    }
}
