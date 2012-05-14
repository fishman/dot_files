#!/usr/bin/perl
#
# (c) 2007 by Robert Manea

use Weather::Com::Finder;

# Fill with valid values
#
my $PartnerId  = 'FILL_WITH_VALID_VALUE';
my $LicenseKey = 'FILL_WITH_VALID_VALUE';
my $iconpath = '/PATH/TO/THE/ICONS';

my %weatherargs = (
                                        'partner_id' => $PartnerId,
                                        'license'    => $LicenseKey,
);

my $weather_finder = Weather::Com::Finder->new(%weatherargs);

###################################### Fill in your location
my $locations = $weather_finder->find('Regensburg, Germany');

my $temp_today =
    $locations->[0]->current_conditions()->temperature();
my $desc_today = $locations->[0]->current_conditions()->icon();

my $forecast = $locations->[0]->forecast();
my $temp_tomorrow =
    $forecast->day(1)->high();
my $desc_tomorrow = $forecast->day(1)->day->icon();
    $forecast->day(1)->day->conditions;
my $temp_dat =
    $forecast->day(2)->high();
my $desc_dat = $forecast->day(2)->day->icon();

my $wvar =
          "^i(${iconpath}/${desc_today}-scaled.xpm)^p(2)${temp_today}°".
          "^p(4)^i(${iconpath}/${desc_tomorrow}-scaled.xpm)^p(2)${temp_tomorrow}°". 
          "^p(4)^i(${iconpath}/${desc_dat}-scaled.xpm)^p(2)${temp_dat}°^p(4)^r(3x3)";


print "$wvar", "\n";
