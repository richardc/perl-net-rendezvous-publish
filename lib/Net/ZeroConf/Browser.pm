package Net::ZeroConf::Browser;
use strict;
use warnings;
use base qw( Class::Accessor::Lvalue );
__PACKAGE__->mk_accessors(qw( _session _handle services ));

=head1 NAME

  Net::ZeroConf::Browser - a service on a zeroconf network

=head1 SYNOPSIS

  use Net::ZeroConf;
  my $z = Net::ZeroConf->new;
  # look for web servers
  my $browser = $z->browse( type => "_http._tcp" );
  # handle callbacks for 10 seconds
  for (1..100) { $z->step( 0.1 ) }

  # see what services we now know about
  for my $service ($browser->services) {
       print $service->name, "\n";
  }
  $browser->stop;

=head1 DESCRIPTION

=cut

sub new {
    my $class = shift;
    return $class->SUPER::new({ services => {} });
}

sub stop {
    my $self = shift;
    $self->_session->_backend->browse_stop( $self->_handle );
}

sub _browse_callback {
    my $self = shift;
    my %message;

    @message{ qw( name type domain kind more ) } = @_;

    if ($message{kind} eq 'add') {
        $self->services->{ $message{type} }{ $message{name} } =
          Net::ZeroConf::Service->new(\%message );
        return;
    }
    if ($message{kind} eq 'remove') {
        delete $self->services->{ $message{type} }{ $message{name} };
        return;
    }
    use YAML;
    warn "Unhandled browser message: " . Dump \%message;
}

1;
