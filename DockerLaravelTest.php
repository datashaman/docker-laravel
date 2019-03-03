<?php

namespace Tests;

use Illuminate\Bus\Queueable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Log;
use Mockery;

class ExampleJob
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function handle()
    {
        Log::warning('ExampleJob dispatched');
    }
}

class DockerLaravelTest extends TestCase
{
    public function tearDown()
    {
        Mockery::close();
        parent::tearDown();
    }

    public function testBeanstalkd()
    {
        Log::shouldReceive('warning')->with('ExampleJob dispatched');
        dispatch(ExampleJob::class);
    }

    public function testBeanstalkdConsole()
    {
    }

    public function testElasticsearch()
    {
    }

    public function testMailhog()
    {
    }

    public function testDb()
    {
    }

    public function testMemcached()
    {
    }

    public function testMinio()
    {
    }

    public function testRedis()
    {
    }

    public function testRedisCommander()
    {
    }

    public function testWeb()
    {
    }

    public function testApp()
    {
    }

    public function testWorker()
    {
    }
}
