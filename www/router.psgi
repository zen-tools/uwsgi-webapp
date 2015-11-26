#!/usr/bin/perl
use strict;
use warnings;

use Plack::Request;
use App::Control::Home;
use App::Control::Product;
use App::Control::Contact;
use App::Control::About;

my %ROUTING = (
    '/'        => App::Control::Home->new(),
    '/product' => App::Control::Product->new(),
    '/contact' => App::Control::Contact->new(),
    '/about'   => App::Control::About->new(),
);


my $app = sub {
    my $env = shift;

    my $request = Plack::Request->new($env);
    my $route = $ROUTING{$request->path_info};
    if ($route) {
        return $route->run($request);
    }
    return [
        '404',
        [ 'Content-Type' => 'text/html' ],
        [ '404 Not Found' ],
    ];
};

