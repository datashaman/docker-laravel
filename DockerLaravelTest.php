<?php

namespace Tests\Feature;

use Cache;
use Elasticsearch\ClientBuilder;
use Illuminate\Bus\Queueable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Log;
use Tests\TestCase;

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
    public function testBeanstalkd()
    {
        Log::shouldReceive('warning')->with('ExampleJob dispatched');
        dispatch(new ExampleJob());
    }

    public function testBeanstalkdConsole()
    {
    }

    public function testElasticsearch()
    {
        $client = ClientBuilder::create()
            ->setHosts(['elasticsearch:9200'])
            ->build();
        $this->assertNotNull($client->info());
    }

    public function testMailhog()
    {
    }

    public function testDb()
    {
    }

    public function testMemcached()
    {
        Cache::put('test', 1234);
        $this->assertEquals(1234, Cache::get('test'));
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
