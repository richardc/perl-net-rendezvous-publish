use strict;
package Net::ZeroConf::Backend;

sub new {
    my $self = shift;
    bless {}, ref $self || $self;
}

1;
__END__

=head1 NAME

Net::ZeroConf::Backend - notes for backend authors plus a base class

=head1 SYNOPSIS

 package Net::ZeroConf::Backend::SomeLibrary;
 use base 'Net::ZeroConf::Backend';

 # the devil will be in the details
 ...

=head1 DESCRIPTION

Net::ZeroConf::Backend is a desert topping and a floor wax, or
rather it's notes for backend interface authors, and a base class
that you'll want to use.


