package Net::ZeroConf::Service;
use strict;
use warnings;
use base qw( Class::Accessor::Lvalue );
__PACKAGE__->mk_accessors(qw( _session _handle name type port domain published ));

=head1 NAME

  Net::ZeroConf::Service - a service on a zeroconf network

=head1 SYNOPSIS

  use Net::ZeroConf;
  my $z = Net::ZeroConf->new;
  # publish a webserver on an odd port
  my $service = $z->publish( name => "My Webserver",
                             type => "_http._tcp",
                             port => 8231 );
  # handle callbacks for 10 seconds
  for (1..100) { $z->step( 0.1 ) }

  # stop publishing the service
  $service->stop;

=head1 DESCRIPTION

=cut

sub stop {
    my $self = shift;
    $self->_session->_backend->publish_stop( $self->_handle );
    $self->published = 0;
}

sub _publish_callback {
    my $self = shift;
    my $result = shift;
    $self->published = $result eq 'success' ? 1 : 0;
}


1;
