package Net::Rendezvous::Publish;
use strict;
use warnings;
use Net::Rendezvous::Publish::Service;

use Module::Pluggable
  search_path => [ "Net::Rendezvous::Publish::Backend" ],
  sub_name    => 'backends';

use base qw( Class::Accessor::Lvalue );
__PACKAGE__->mk_accessors(qw( _backend _published ));

our $VERSION = 0.01;

sub new {
    my $class = shift;
    my %args = @_;

    my $self = $class->SUPER::new;

    my ($backend) = $args{backend} || $self->backends;
    eval "require $backend" or die $@;
    return unless $backend;
    $self->_backend = $backend->new
      or return;
    $self->_published = [];
    return $self;
}

sub publish {
    my $self = shift;
    my $service = Net::Rendezvous::Publish::Service->new;
    $service->_session = $self;
    $service->_handle  = $self->_backend->publish( object => $service, @_ )
      or return;
    return $service;
}

sub step {
    my $self = shift;
    $self->_backend->step( shift );
    return $self;
}


1;

__END__

=head1 NAME

Net::Rendezvous::Publish - publish Rendezvous services

=head1 SYNOPSIS

 use Net::Rendezvous::Publish;
 my $publisher = Net::Rendezvous::Publish->new
   or die "couldn't make a Responder object";
 my $sevice = $publisher->publish(
     name => "My HTTP Server",
     type => 'http',
     port => 12345,
 );
 while (1) { $publisher->step( 0.01 ) }

=head1 DESCRIPTION

=head1 METHODS

=head2 new

Creates a new publisher handle

=head2 publish( %definition )

Returns a Net::Rendezvous::Publish::Service object.  The following
keys are meaningful in the service definition hash.

=over

=item type

=back


=head1 SEE ALSO

L<Net::Rendezvous::Publish::Backend::*> - you'll need one of these to talk
to your local mDNS responder.

=cut
