#!/usr/bin/perl -w
#
# gcal2rem.pl modded from ical2rem.pl
#
# just added a wget pipe from public gcal
#
###

use strict;
use iCal::Parser;
use DateTime;
use Pod::Usage;
use Data::Dumper;

# Declare how many days in advance to remind
my $DEFAULT_LEAD_TIME = 3;
my $PROCESS_TODOS     = 1;
my $HEADING           = "";

# url to public gcal (ical format)
my $URL = "http://www.google.com/calendar/ical/pbrisbin%40gmail.com/public/basic.ics";

my $label = 'Calendar';
my $month = ['None','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

my @calendars;
my $in;

open(INPUT, "/usr/bin/wget -q -O - $URL |");

while(<INPUT>) {
        $in .= $_;
        if (/END:VCALENDAR/) {
        	push(@calendars,$in);
                $in = "";
        }
}

close(INPUT);

my $parser = iCal::Parser->new();
my $hash = $parser->parse_strings(@calendars);

##############################################################
#
# Subroutines 
#
#############################################################
#
# _process_todos()
# expects 'todos' hashref from iCal::Parser is input
# returns String to output
sub _process_todos {
	my $todos = shift; 
	
	my ($todo, @newtodos, $leadtime);
	my $output = "";

	$output .=  'REM '.$HEADING.' MSG '.$label.' ToDos:%"%"%'."\n";

# For sorting, make sure everything's got something
#   To sort on.  
	my $now = DateTime->now;
	for $todo (@{$todos}) {
		# remove completed items
		if ($todo->{'STATUS'} && $todo->{'STATUS'} eq 'COMPLETED') {
			next;
		} elsif ($todo->{'DUE'}) {
			# All we need is a due date, everything else is sugar
			$todo->{'SORT'} = $todo->{'DUE'}->clone;
		} elsif ($todo->{'DTSTART'}) {
			# for sorting, sort on start date if there's no due date
			$todo->{'SORT'} = $todo->{'DTSTART'}->clone;
		} else {
			# if there's no due or start date, just make it now.
			$todo->{'SORT'} = $now;
		}
		push(@newtodos,$todo);
	}
	if (! (scalar @newtodos)) {
		return "";
	}
# Now sort on the new Due dates and print them out.  
	for $todo (sort { DateTime->compare($a->{'SORT'}, $b->{'SORT'}) } @newtodos) {
		my $due = $todo->{'SORT'}->clone();
		my $priority = "";
		if (defined($todo->{'PRIORITY'})) {
			if ($todo->{'PRIORITY'} == 1) {
				$priority = "PRIORITY 1000";
			} elsif ($todo->{'PRIORITY'} == 3) {
				$priority = "PRIORITY 7500";
			}
		}
		if (defined($todo->{'DTSTART'}) && defined($todo->{'DUE'})) {
			# Lead time is duration of task + lead time
			my $diff = ($todo->{'DUE'}->delta_days($todo->{'DTSTART'})->days())+$DEFAULT_LEAD_TIME;
			$leadtime = "+".$diff;
		} else {
			$leadtime = "+".$DEFAULT_LEAD_TIME;
		}
		$output .=  "REM ".$due->month_abbr." ".$due->day." ".$due->year." $leadtime $priority MSG \%a $todo->{'SUMMARY'}\%\"\%\"\%\n";
	}
	$output .= 'REM '.$HEADING.' MSG %"%"%'."\n";
	return $output;
}


#######################################################################
#
#  Main Program
#
######################################################################

print _process_todos($hash->{'todos'}) if $PROCESS_TODOS;

my ($leadtime, $yearkey, $monkey, $daykey,$uid,%eventsbyuid);
print 'REM '.$HEADING.' MSG '.$label.' Events:%"%"%'."\n";
my $events = $hash->{'events'};
foreach $yearkey (sort keys %{$events} ) {
    my $yearevents = $events->{$yearkey};
    foreach $monkey (sort {$a <=> $b} keys %{$yearevents}){
        my $monevents = $yearevents->{$monkey};
        foreach $daykey (sort {$a <=> $b} keys %{$monevents} ) {
            my $dayevents = $monevents->{$daykey};
            foreach $uid (sort {
                            DateTime->compare($dayevents->{$a}->{'DTSTART'}, $dayevents->{$b}->{'DTSTART'})    
                            } keys %{$dayevents}) {
                my $event = $dayevents->{$uid};
               if ($eventsbyuid{$uid}) {
                    my $curreventday = $event->{'DTSTART'}->clone;
                    $curreventday->truncate( to => 'day' );
                    $eventsbyuid{$uid}{$curreventday->epoch()} =1;
                    for (my $i = 0;$i < $DEFAULT_LEAD_TIME && !defined($event->{'LEADTIME'});$i++) {
                        if ($eventsbyuid{$uid}{$curreventday->subtract( days => $i+1 )->epoch() }) {
                            $event->{'LEADTIME'} = $i;
                        }
                    }
                } else {
                    $eventsbyuid{$uid} = $event;
                    my $curreventday = $event->{'DTSTART'}->clone;
                    $curreventday->truncate( to => 'day' );
                    $eventsbyuid{$uid}{$curreventday->epoch()} =1;
                }

            }
        }
    }
}
foreach $yearkey (sort keys %{$events} ) {
    my $yearevents = $events->{$yearkey};
    foreach $monkey (sort {$a <=> $b} keys %{$yearevents}){
        my $monevents = $yearevents->{$monkey};
        foreach $daykey (sort {$a <=> $b} keys %{$monevents} ) {
            my $dayevents = $monevents->{$daykey};
            foreach $uid (sort {
                            DateTime->compare($dayevents->{$a}->{'DTSTART'}, $dayevents->{$b}->{'DTSTART'})
                            } keys %{$dayevents}) {
                my $event = $dayevents->{$uid};
                if (exists($event->{'LEADTIME'})) {
                    $leadtime = "+".$event->{'LEADTIME'};
                } else {
                    $leadtime = "+".$DEFAULT_LEAD_TIME;
                }
                my $start = $event->{'DTSTART'};
                print "REM ".$start->month_abbr." ".$start->day." ".$start->year." $leadtime ";
                if ($start->hour > 0) { 
                    print " AT ";
                    print $start->strftime("%H:%M");
                    print " SCHED _sfun MSG %a %2 ";
                } else {
                    print " MSG %a ";
                }
                print "%\"$event->{'SUMMARY'}";
                print " at $event->{'LOCATION'}" if $event->{'LOCATION'};
                print "\%\"%\n";
            }
        }
    }
}
exit 0;

#:vim set ft=perl ts=4 sts=4 expandtab :
