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

Net::ZeroConf - perl interface to ZeroConf/Rendezvous

=head1 SYNOPSIS

 use YAML;
 use Net::ZeroConf;
 my $zeroconf = Net::ZeroConf->new or die "couldn't make a ZeroConf object";
 print "Known services:\n", Dump $zeroconf->services;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

Create a new zeroconf interface

=head2 services

list the known services

=head1 SEE ALSO

L<Net::ZeroConf::Backend> - notes for backend writers

=cut
