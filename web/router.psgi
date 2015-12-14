#!/usr/bin/perl
use strict;
use warnings;

use Plack::Request;
use File::Basename;

use App::Control::Home;
use App::Control::Product;
use App::Control::Contact;
use App::Control::About;

my %ROUTING = (
    '/'        => 'App::Control::Home',
    '/product' => 'App::Control::Product',
    '/contact' => 'App::Control::Contact',
    '/about'   => 'App::Control::About',
);

my $app = sub {
    my $env = shift;
    use Data::Dumper;

    my $request = Plack::Request->new($env);
    my $route = $ROUTING{$request->path_info};
    if ($route) {
        $route = $route->new(
            webroot => dirname(__FILE__)
        );
        return $route->run($request);
    }
    return [
        '404',
        [ 'Content-Type' => 'text/html' ],
        [ '404 Not Found' ],
    ];
};

