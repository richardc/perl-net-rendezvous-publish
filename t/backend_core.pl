use Sys::Hostname;
use Test::More tests => 9;
use Net::ZeroConf;

my $type  = "_madeup._tcp.";
my $name  = "$class $type $$";
diag( "using service name '$name'" );

my $session = Net::ZeroConf->new( backend => $class );
ok( $session,  "Created a session" );

my $browser = $session->browse( type => $type );
ok( $browser, "Made a browser" );

spin();

my $service = $session->publish( type => $type,
                                 port => 80,
                                 name => $name );
ok( $service, "Published a service" );
is( $service->published, undef, "Don't know if it's been acked yet" );

spin();

ok( $service->published, "Time has passed, and now it is" );

# by now the browser should know of that service
ok( $browser->services->{ $type }{ $name },
    "browser saw the service we advertised" );

print "# stopping service\n";
$service->stop;

spin();

ok( !$service->published, "service thinks it isn't published" );

ok( !$browser->services->{ $type }{ $name },
    "browser no longer sees the stopped service" );

print "# stopping the browser\n";
$browser->stop;

spin();

print "# starting another service for the browser to not see\n";
my $second = $session->publish( type => $type,
                                port => 80,
                                name => "$name 2" );

spin();

use YAML;
warn Dump $browser->services;

ok( !$browser->services->{ $type }{ "$name 2" },
    "stopped browser didn't see the new service" );

# handle some events
sub spin {
    $session->step( 0.1 ) for 1..20;
}

1;
