use inc::Module::Install;

name 'Jirago';
all_from 'lib/Jirago.pm';

requires 'Moose';
requires 'Config::JFDI';
requires 'JIRA::Client';
requires 'DateTimeX::Easy';

requires 'YAML';

install_script glob('script/*.pl');
auto_install;
WriteAll;
