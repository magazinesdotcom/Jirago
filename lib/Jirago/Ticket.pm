package Jirago::Ticket;

use Moose;
use Moose::Util::TypeConstraints;

has [ 'id', 'name' ] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

enum 'TicketStates' => qw( open ready_for_qa in_qa closed );

has 'state' => (
    is       => 'ro',
    isa      => 'TicketStates',
    required => 1,
);

has 'reopened' => (
    is       => 'ro',
    isa      => 'Bool',
    default  => 0,
);


has 'category' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;
