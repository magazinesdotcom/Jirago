package Jirago::Release;

use Moose;

has 'source' => (
    is       => 'ro',
    does     => 'Jirago::Source',
    required => 1,
);

has 'name' => (
    is  => 'ro',
    isa => 'Str'
);

has 'freeze_date' => (
    is  => 'ro',
    isa => 'DateTime'
);

has 'release_date' => (
    is  => 'ro',
    isa => 'DateTime'
);

sub in_code_freeze {
    my ( $self ) = @_;

    my $now = DateTimeX::Easy->new('today');

    return ( $self->freeze_date >= $now );
}

has 'tickets' => (
    is          => 'ro',
    isa         => 'ArrayRef[Jirago::Ticket]',
    lazy_build  => 1,
    traits      => [ 'Array' ],
    handles => {
        'all_tickets' => 'elements',
    }
);

sub _build_tickets {
    my $self = shift;
    $self->source->_build_tickets( $self->name );
}

has 'open_tickets' => (
    is          => 'ro',
    isa         => 'ArrayRef[Jirago::Ticket]',
    lazy_build  => 1,
    traits      => [ 'Array' ],
    handles => {
        'get_open_tickets'  => 'elements',
        'open_ticket_count' => 'count',
    }
);

sub _build_open_tickets {
    my ( $self ) = @_;
    [ grep { $_->state eq 'open' } $self->all_tickets ];
}

has 'reopened_tickets' => (
    is          => 'ro',
    isa         => 'ArrayRef[Jirago::Ticket]',
    lazy_build  => 1,
    traits      => [ 'Array' ],
    handles => {
        'get_reopened_tickets'  => 'elements',
        'reopened_ticket_count' => 'count',
    }
);

sub _build_reopened_tickets {
    my ( $self ) = @_;
    [ grep { $_->state eq 'open' && $_->reopened } $self->all_tickets ];
}

has 'closed_tickets' => (
    is          => 'ro',
    isa         => 'ArrayRef[Jirago::Ticket]',
    lazy_build  => 1,
    traits      => [ 'Array' ],
    handles => {
        'get_closed_tickets'  => 'elements',
        'closed_ticket_count' => 'count',
    }
);

sub _build_closed_tickets {
    my ( $self ) = @_;
    [ grep { $_->state eq 'closed' } $self->all_tickets ];
}

has 'pending_tickets' => (
    is          => 'ro',
    isa         => 'ArrayRef[Jirago::Ticket]',
    lazy_build  => 1,
    traits      => [ 'Array' ],
    handles => {
        'get_pending_tickets'  => 'elements',
        'pending_ticket_count' => 'count',
    }
);

sub _build_pending_tickets {
    my ( $self ) = @_;
    [ grep { $_->state ne 'closed' and $_->state ne 'open' } $self->all_tickets ];
}

no Moose;
__PACKAGE__->meta->make_immutable;
