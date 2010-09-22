package Jirago::Source::JIRA;

use Moose;
use JIRA::Client;
use DateTimeX::Easy;

use Jirago::Ticket;
use Jirago::Release;

with 'Jirago::Source';

has 'jira' => (
    is          => 'ro',
    isa         => 'JIRA::Client',
    lazy_build  => 1,
);

has [ 'url', 'username', 'password', 'project', 'issue_filter' ] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has 'statuses' => (
    is          => 'ro',
    isa         => 'HashRef',
    traits      => [ 'Hash' ],
    lazy_build  => 1,
    handles => {
        'get_status' => 'get'
    }
);

sub _build_jira {
    my ( $self ) = @_;
    JIRA::Client->new( $self->url, $self->username, $self->password );
}

sub _build_statuses {
    my ( $self ) = @_;
    my %ret =
        map { $_->{id} => $_->{name} }
        values %{ $self->jira->get_statuses };
    return \%ret;
}

sub _build_next_release {
    my ( $self ) = @_; 
    my $now = DateTimeX::Easy->new('now');

    my $r;

    my @releases = values %{ $self->jira->get_versions( $self->project ) };
    foreach my $rel ( sort { $a->{sequence} <=> $b->{sequence} } @releases ) {
        next if $rel->{released};
        $r = $rel;
        last;
        my $date = DateTimeX::Easy->parse( $rel->{releaseDate} );
        next if ( $date < $now );

    }
    my $date = DateTimeX::Easy->parse( $r->{releaseDate} );
    Jirago::Release->new(
        name         => $r->{name},
        freeze_date  => $date->clone->subtract( days => 7 ),
        release_date => $date,
        source       => $self,
    );
}

sub _build_categories { 
    my ( $self ) = @_;
    return [ keys %{ $self->jira->get_components( $self->project ) } ];
}

sub _build_tickets {
    my ( $self, $version ) = @_;
    $self->jira->set_filter_iterator( $self->issue_filter );
    $version ||= $self->next_release->name;
    my @tickets = ();
    while ( my $issue = $self->jira->next_issue ) {
        my @versions = ref $issue->{fixVersions} ?
            @{ $issue->{fixVersions} } : ( $issue->{fixVersions} );
        next unless grep { $_->{name} eq $version } @versions;

        my @components = ref $issue->{components} ?
            @{ $issue->{components} } : ( $issue->{components} );

        my $s = $self->get_status( $issue->{status} );

        my $state = ( $issue->{resolution} or $s eq 'Closed' ) ? 'closed' :
                    $s =~ /^(Under Quality Review|Closed|Resolved)$/ ?
                        'ready_for_qa' : 'open';
        push @tickets, Jirago::Ticket->new(
            id       => $issue->{key},
            name     => $issue->{summary},
            category => $components[0]->{name} || 'Unset',
            state    => $state,
        );
    }

    return \@tickets;
}

no Moose;
__PACKAGE__->meta->make_immutable;
