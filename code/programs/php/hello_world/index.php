<?php

require __DIR__ . '/vendor/autoload.php';

use App\HelloWorld;

$greeter = new HelloWorld();
$greeter->sayHello();