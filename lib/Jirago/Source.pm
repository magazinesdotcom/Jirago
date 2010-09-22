package Jirago::Source;

use Moose::Role;

has 'next_release' => (
    is          => 'ro',
    isa         => 'Jirago::Release',
    lazy_build  => 1,
    handles => {
        'next_release_date' => 'release_date',
        'next_freeze_date'  => 'freeze_date'
    }
);
requires '_build_next_release';

has 'categories' => (
    is          => 'ro',
    isa         => 'ArrayRef[Str]',
    lazy_build  => 1,
    traits      => [ 'Array' ],
    handles => {
        'get_categories' => 'elements',
    }
);

requires '_build_categories';

no Moose::Role;
1;

