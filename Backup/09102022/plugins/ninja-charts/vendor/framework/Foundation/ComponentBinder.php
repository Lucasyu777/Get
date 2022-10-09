<?php

namespace NinjaCharts\Framework\Foundation;

use NinjaCharts\Framework\View\View;
use NinjaCharts\Framework\Rest\Rest;
use NinjaCharts\Framework\Request\Request;
use NinjaCharts\Framework\Response\Response;
use NinjaCharts\Framework\Database\Orm\Model;
use NinjaCharts\Framework\Validator\Validator;
use NinjaCharts\Framework\Foundation\Dispatcher;
use NinjaCharts\Framework\Foundation\RequestGuard;
use NinjaCharts\Framework\Database\ConnectionResolver;
use NinjaCharts\Framework\Database\Query\WPDBConnection;
use NinjaCharts\Framework\Foundation\UnAuthorizedException;

class ComponentBinder
{
    protected $app = null;

    protected $bindables = [
        'Request',
        'Response',
        'Validator',
        'View',
        'Events',
        'DataBase',
        'Rest'
    ];

    public function __construct($app)
    {
        $this->app = $app;
    }

    public function bindComponents()
    {
        foreach ($this->bindables as $value) {
            $method = "bind{$value}";
            $this->{$method}();
        }

        $this->extendBindings();
    }

    protected function bindRequest()
    {
        $this->app->singleton(Request::class, function ($app) {
            return new Request($app, $_GET, $_POST, $_FILES);
        });

        $this->app->alias(Request::class, 'request');
    }

    protected function bindResponse()
    {
        $this->app->singleton(Response::class, function($app) {
            return new Response($app);
        });

        $this->app->alias(Response::class, 'response');
    }

    protected function bindValidator()
    {
        $this->app->bind(Validator::class, function($app) {
            return new Validator;
        });

        $this->app->alias(Validator::class, 'validator');
    }

    protected function bindView()
    {
        $this->app->bind(View::class, function($app) {
            return new View($app);
        });

        $this->app->alias(View::class, 'view');
    }

    protected function bindEvents()
    {
        $this->app->singleton(Dispatcher::class, function($app) {
            return new Dispatcher($app);
        });

        $this->app->alias(Dispatcher::class, 'events');
    }

    protected function bindDataBase()
    {
        $this->app->bindShared('db', function($app) {
            return new WPDBConnection(
                $GLOBALS['wpdb'], $app->config->get('database')
            );
        });

        Model::setEventDispatcher($this->app['events']);

        Model::setConnectionResolver(new ConnectionResolver);
    }

    protected function bindRest()
    {
        $this->app->singleton('rest', function($app) {
            return new Rest($app);
        });
    }

    protected function extendBindings()
    {
        $bindings = $this->app['path'] . 'boot/bindings.php';

        if (is_readable($bindings)) {
            require_once $bindings;
        }
    }
}
