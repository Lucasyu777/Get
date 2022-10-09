<?php

namespace NinjaCharts\Http\Requests;

use NinjaCharts\Framework\Foundation\RequestGuard;

abstract class Request extends RequestGuard
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [];
    }

    public function messages()
    {
        return [];
    }
}
