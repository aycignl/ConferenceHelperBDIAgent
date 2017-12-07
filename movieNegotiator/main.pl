#!/usr/bin/env perl
use warnings;
use strict;
use v5.14;

our @users;
our $nUsers;
our @offerHistory = ();
our @offerHistory2 = ();
our %utilities = ();
our %preferenceLists = ();
our %receivedOffers = ();
our %lastResponses = ();
our $nPreferences = 0;
our $graphfile = 'negotiationTable.dot';
our %knownAgents = ();
our $goal = 'consensus';
our $protocol = 'GP';
our $turn;
our $bestOfferFrom2to0 = 0;
our $bestUtilityFrom2to0 = 0;
our $logging = "disabled";
our $filename;
our $filename_wOutExt;
our $l = 0;
our $delay = 0;

sub goal {
    return ($goal eq 'consensus') ? consensus() : majority();
}

sub simulate {
    if ($protocol eq "GP") {
        simulateGonulProtocol();
    } elsif ($protocol eq "YP") {
        simulateYavuzProtocol();
    } else {
        die("Illegal Protocol");
    }
}

sub utility {
    my $user = shift @_ or die("Illegal Argument Exception");
    my $m = shift @_ or die("Illegal Argument Exception");
    
    return (defined $utilities{"$user,$m"}) ? $utilities{"$user,$m"} : 0;
}

sub consensus {
    return 0 if (scalar keys %lastResponses == 0);
    my $firstUsersResponse = $lastResponses{$users[0]};
    if ($firstUsersResponse =~ /ACCEPT\((\S+)\)/) {
        my $count = 0;
        for (values %lastResponses) {
            $count++ if ($_ eq $firstUsersResponse);
        }
        return $count >= $nUsers;
    } else {
        return 0;
    }
}

sub majority {
    my $firstUsersResponse = $lastResponses{$users[0]};
    if ($firstUsersResponse =~ /ACCEPT\((\S+)\)/) {
        my $count = 0;
        for (values %lastResponses) {
            $count++ if ($_ eq $firstUsersResponse);
        }
        return 2*$count > $nUsers;
    } else {
        return 0;
    }
}

sub broken {
    for (values %lastResponses) {
        return 1 if ($_ eq "BREAK");
    }
    return 0;
}

sub getGraphHeader {
    if ($nUsers == 2) {
        my ($u1, $u2) = @users;
        return "digraph NegotiatingTable {\n\trankdir=LR\n\t$u1->$u2 [style=invis]";
    } elsif ($nUsers == 3) {
        my ($u1, $u2, $u3) = @users;
        return "digraph NegotiatingTable {\n\trankdir=LR\n\t$u1->$u2 [style=invis]\n\t$u2->$u3 [style=invis]\n\t$u3->$u1 [style=invis]";
    } else {
        die("This feature is not implemented yet!");
    }
}

sub getGraphFooter {
    return '}';
}

sub drawGraph {
    open(FILE, '>', $graphfile);
    say FILE getGraphHeader();
    my $i = scalar @offerHistory - 1;
    my $lastOffer = $i >= 0 ? $offerHistory[$i] : "";
    my $lastOfferedMovie = $lastOffer =~ /\S+,\S+,(\S+)/ ? $1 : -1;
    my %exploredUsers = ();
    my $YPcount = 0;
    until ($i < 0 or scalar keys %exploredUsers >= $nUsers) {
        my $offer = $offerHistory[$i];
        if ($offer =~ /(\S+),(\S+),(\S+)/) {
            my ($u1, $u2, $m) = ($1, $2, $3);
            if ($u1 eq $users[0] and $protocol eq "YP" and $nUsers > 2) {
                $exploredUsers{$u1} = 1 if ($YPcount);
                $YPcount = 1;
            } else {
                $exploredUsers{$u1} = 1;
            }
            if ($m == $lastOfferedMovie) {
                say FILE "\t$u1->$u2 [label=\"o($m)\"]";
            } else {
                say FILE "\t$u1->$u2 [style=dashed,label=\"o($m)\"]";
            }
        }
        $i--;
    }
    for my $u (keys %lastResponses) {
        if ($lastResponses{$u} ne "CONTINUE") {
            if (prevGonulUser($turn) eq $u) {
                say FILE "\t$u->$u [label=\"$lastResponses{$u}\"]";
            } else {
                say FILE "\t$u->$u [color=gray55,fontcolor=gray55,label=\"$lastResponses{$u}\"]";
            }
        }
    }
    say FILE getGraphFooter();
    close(FILE);
    if ($logging eq "enabled") {
        $l++;
        `dot -Tpdf <$graphfile >report/figures/$filename_wOutExt/$protocol$l.pdf`;
        select(undef, undef, undef, $delay/1000.0);
    }
}

sub pause {
    my $readAnyKeyCmd = 'read -n1 -r -p "Press any key to continue..." key';

    say "";
    `$readAnyKeyCmd`;
    system('clear');
    say "";
}   

sub nextGonulUser {
    return $users[nextGonulTurn()];
}

sub prevGonulUser {
    my $oldTurn = $turn;
    do {
        $oldTurn = $oldTurn > 0 ? $oldTurn - 1 : $nUsers - 1;
    } while (defined $knownAgents{$oldTurn});
    return $users[$oldTurn];
}

sub nextGonulTurn {
    my $newTurn = $turn;
    do {
        $newTurn = ($newTurn < $nUsers - 1) ? $newTurn + 1 : 0;
    } while (defined $knownAgents{$newTurn});
    return $newTurn;
}

sub makeGonulOffer {
    my $user = shift @_ or die("Illegal Argument Exception");
    
    my $bestMovie = 0;
    my $bestUtility = 0;
    my $counteroffer = "NO";
    my $accept = 0;
    if (@{$preferenceLists{$user}} > 0) {
        say "$user\'s remaining preferences = " . join(',', @{$preferenceLists{$user}});
        $counteroffer = "YES";
        my $arr_ref = $preferenceLists{$user};
        $bestMovie = $arr_ref->[0];
        $bestUtility = utility($user, $bestMovie);
        say "Considering movie $bestMovie from $user\'s preferences";
        say "U_$user($bestMovie) = $bestUtility\n";
    } else {
        say "$user has no preferences left to offer :/";
    }
    for my $receivedOffer (@{$receivedOffers{$user}}) {
        if ($receivedOffer =~ /(\S+),\S+,(\S+)/) {
            my ($sender, $m) = ($1, $2);
            my $newUtility = utility($user, $m);
            say "Received Offer = $m from $sender, with U($m) = " . $newUtility;
            if ($newUtility and $newUtility >= $bestUtility) {
                say "Considering movie $m offered by $sender";
                say "U_$user($m) = " . $newUtility;
                $bestMovie = $m;
                $bestUtility = $newUtility;
                $counteroffer = ($newUtility == $bestUtility ? "YES" : "NO");
                $accept = 1;
            }
        }
    }
    say "" if (@{$receivedOffers{$user}} > 0);
    
    if ($bestUtility == 0 or $bestUtility < $bestUtilityFrom2to0) {
        say "$user BREAKS the negotiations";        
        $lastResponses{$user} = "BREAK";
        return;
    }
    
    if ($counteroffer eq "YES") {
        shift @{$preferenceLists{$user}};
    }
        
    my $target = nextGonulUser();
    say "$user offers $bestMovie to $target";
    my $offer = "$user,$target,$bestMovie";
    push @offerHistory, $offer;
    shift @{$receivedOffers{$target}}; # comment out edilirse example8 halt eder.
    push @{$receivedOffers{$target}}, $offer;
    $lastResponses{$user} = ($accept) ? "ACCEPT($bestMovie)" : "CONTINUE";
    
    if ($nUsers == 3 and $target eq $users[0] 
        and utility($users[0],$bestMovie) > $bestUtilityFrom2to0) {
        $bestOfferFrom2to0 = $bestMovie;
        $bestUtilityFrom2to0 = utility($users[0],$bestMovie);
    }
}

sub makeYavuzOffer {
    my $user = shift @_ or die("Illegal Argument Exception");
    
    my $bestMovie = 0;
    my $bestUtility = 0;
    my $counteroffer = "NO";
    my $accept = 0;

    if (@{$preferenceLists{$user}} > 0) {
        say "$user\'s remaining preferences = " . join(',', @{$preferenceLists{$user}});
        $counteroffer = "YES";
        my $arr_ref = $preferenceLists{$user};
        $bestMovie = $arr_ref->[0];
        $bestUtility = utility($user, $bestMovie);
        say "Considering movie $bestMovie from $user\'s preferences";
        say "U_$user($bestMovie) = $bestUtility\n";
    } else {
        say "$user has no preferences left to offer :/";
    }        
    for my $receivedOffer (@{$receivedOffers{$user}}) {
        if ($receivedOffer =~ /(\S+),\S+,(\S+)/) {
            my ($sender, $m) = ($1, $2);
            my $newUtility = utility($user, $m);
            say "Received Offer = $m from $sender, with U($m) = " . $newUtility;
            if ($newUtility and $newUtility >= $bestUtility) {
                say "Considering movie $m offered by $sender";
                say "U_$user($m) = " . $newUtility;
                $bestMovie = $m;
                $bestUtility = $newUtility;
                $counteroffer = ($newUtility == $bestUtility ? "YES" : "NO");
                $accept = 1;
            }
        }
    }
    say "" if (@{$receivedOffers{$user}} > 0);
    
    if ($bestMovie == 0) {
        say "$user BREAKS the negotiations";        
        $lastResponses{$user} = "BREAK";
        return;
    }
    
    if ($counteroffer eq "YES") {
        shift @{$preferenceLists{$user}};
    }
    
    if ($user eq $users[0]) {
        for my $target (@users) {
            if ($target ne $user) {
                say "$user offers $bestMovie to $target";
                my $offer = "$user,$target,$bestMovie";
                push @offerHistory, $offer;
                shift @{$receivedOffers{$target}}; # comment out edilirse example8 halt eder.
                push @{$receivedOffers{$target}}, $offer;
            }
        }
        $lastResponses{$user} = ($accept) ? "ACCEPT($bestMovie)" : "CONTINUE";
    } else {
        my $target = $users[0];
        say "$user offers $bestMovie to $target";
        my $offer = "$user,$target,$bestMovie";
        push @offerHistory, $offer;
        shift @{$receivedOffers{$target}} if (scalar @{$receivedOffers{$target}} == 2); 
        push @{$receivedOffers{$target}}, $offer;
        $lastResponses{$user} = ($accept) ? "ACCEPT($bestMovie)" : "CONTINUE";        
    }
}

sub renewPreferenceLists {
    my $count = 0;
    for my $key (keys %utilities) {
        $key =~ /(\S+),\S+/;
        $count++ if ($1 eq $users[0]);
    }
    for my $key (keys %utilities) {
        $key =~ /(\S+),(\S+)/;
        my ($u, $m) = ($1, $2);
        if (!defined $knownAgents{$u}) {
            my $utility = utility($u, $m);
            $preferenceLists{$u}->[$count - $utility] = $m;
        }
    }
}

sub simulateGonulProtocol {
    $turn = 0;
    until (goal() or broken()) {
        drawGraph();
        pause();

        my $user = $users[$turn];
        say "It\'s $user\'s turn!\n";
        
        makeGonulOffer($user);
        $turn = nextGonulTurn();        
    }
    
    drawGraph();
    if (consensus()) {
        my $offer = $offerHistory[scalar @offerHistory - 1];
        $offer =~ /\S+,\S+,(\S+)/;
        my $m = $1;        
        my $friends = join ',',@users;
        $friends =~ s/[^,]+,//;
        print "$users[0] goes to movie $m with her friend".(($nUsers > 2) ? "s " : " ");
        say "$friends :)\n";
    } elsif ($nUsers == 3) {
        system('clear');
        say "Consensus NOT possible.";
        say "Now, $users[0] will look for Majority.";
        pause();
        
        $lastResponses{$_} = "CONTINUE" for (keys %lastResponses);
        @offerHistory2 = @offerHistory;
        @offerHistory = ();
        
        $goal = 'majority';
        $knownAgents{($nUsers - 1)} = 1;
        renewPreferenceLists();
        $turn = 0;
        $nUsers--;
        until (goal() or broken()) {
            drawGraph();
            pause();

            my $user = $users[$turn];
            say "It\'s $user\'s turn!\n";
        
            makeGonulOffer($user);
            $turn = nextGonulTurn(); 
        }
        
        drawGraph();
        if (majority()) {
            my $lastResponse = $lastResponses{$users[0]};
            $lastResponse =~ /ACCEPT\((\S+)\)/;
            my $selectedMovie = $1;
            
            my $friend = "!";
            for (keys %lastResponses) {
                if ($lastResponses{$_} eq "ACCEPT($selectedMovie)" and $_ ne $users[0]) {
                    $friend = $_;
                }
            }
            
            say "Gonul goes to movie $selectedMovie with her friend, $friend";            
        } else {
            if ($bestUtilityFrom2to0 > 0) {
                my $friend = $users[2];
                say "$users[0] goes to movie $bestOfferFrom2to0 with her friend, $friend";
                say "U_$users[0]($bestOfferFrom2to0) = $bestUtilityFrom2to0";
                say "U_$users[2]($bestOfferFrom2to0) = " . utility($users[2], $bestOfferFrom2to0);
            } else {
                say "$users[0] goes to the cinema alone :/\n";
                my $bestMovie = -1;
                for my $key (sort keys %utilities) {
                    $key =~ /(\S+),(\S+)/;
                    my ($u, $m) = ($1, $2);
                    if ($users[0] eq $u and utility($u, $m) > utility($u, $bestMovie)) {
                        $bestMovie = $m;
                    }
                }
                say "$users[0] goes to movie $bestMovie";                
            }
        }
    } else {
        say "$users[0] goes to the cinema alone :/\n";
        my $bestMovie = -1;
        for my $key (sort keys %utilities) {
            $key =~ /(\S+),(\S+)/;
            my ($u, $m) = ($1, $2);
            if ($users[0] eq $u and utility($u, $m) > utility($u, $bestMovie)) {
                $bestMovie = $m;
            }
        }
        say "$users[0] goes to movie $bestMovie";
    }
}

sub simulateYavuzProtocol {
    $turn = 0;
    until (goal() or broken()) {
        drawGraph();
        pause();

        my $user = $users[$turn];
        say "It\'s $user\'s turn!\n";
        
        makeYavuzOffer($user);
        $turn = nextGonulTurn();        
    }

    drawGraph();
    if (consensus()) {
        my $offer = $offerHistory[scalar @offerHistory - 1];
        $offer =~ /\S+,\S+,(\S+)/;
        my $m = $1;        
        my $friends = join ',',@users;
        $friends =~ s/[^,]+,//;
        print "$users[0] goes to movie $m with her friend".(($nUsers > 2) ? "s " : " ");
        say "$friends :)\n";
    } elsif ($nUsers == 3) {
        system('clear');
        say "Consensus NOT possible.";
        say "Now, $users[0] will look for Majority.";
        pause();
        
        if (majority()) {
            my $lastResponse = $lastResponses{$users[0]};
            $lastResponse =~ /ACCEPT\((\S+)\)/;
            my $selectedMovie = $1;
            
            my $friend = "!";
            for (keys %lastResponses) {
                if ($lastResponses{$_} eq "ACCEPT($selectedMovie)" and $_ ne $users[0]) {
                    $friend = $_;
                }
            }
            
            say "Gonul goes to movie $selectedMovie with her friend, $friend";
        } else {
            say "$users[0] goes to the cinema alone :/\n";
            my $bestMovie = -1;
            for my $key (sort keys %utilities) {
                $key =~ /(\S+),(\S+)/;
                my ($u, $m) = ($1, $2);
                if ($users[0] eq $u and utility($u, $m) > utility($u, $bestMovie)) {
                    $bestMovie = $m;
                }
            }
            say "$users[0] goes to movie $bestMovie";            
        }
    } else {
        say "$users[0] goes to the cinema alone :/\n";
        my $bestMovie = -1;
        for my $key (sort keys %utilities) {
            $key =~ /(\S+),(\S+)/;
            my ($u, $m) = ($1, $2);
            if ($users[0] eq $u and utility($u, $m) > utility($u, $bestMovie)) {
                $bestMovie = $m;
            }
        }
        say "$users[0] goes to movie $bestMovie";
    }
}

sub main {
    $filename = shift @ARGV or die("No file given");
    $filename_wOutExt = $filename;
    $filename_wOutExt =~ s/\..*//g;
    
    $protocol = scalar @ARGV > 0 ? shift @ARGV : "GP";
    if (scalar @ARGV > 0) {
        $logging = "enabled";
        open(STDOUT, ">report/figures/$filename_wOutExt/$protocol.txt") 
            or die ("report/figures/$filename_wOutExt/$protocol.txt !!!");
        $delay = shift @ARGV;
    }

    open(FILE, '<', $filename) or die("Can't open $filename: $!");
    my $firstline = <FILE>;
    @users = split(/,/,$firstline);
    s/\s//g for (@users);
    $nUsers = scalar @users;

    die("We do NOT support more than 3 users yet") if ($nUsers > 3);
    die("No. of users must be 2 or higher") if ($nUsers < 2);
    
    my $currentUtility = 0;
    for (@users) {
        my @arr1 = ();
        my $arr1_ref = \@arr1;
        my @arr2 = ();
        my $arr2_ref = \@arr2;
        $preferenceLists{$_} = $arr1_ref;
        $receivedOffers{$_} = $arr2_ref;
    }
    while (<FILE>) {
        my $i = 0;
        for my $m (split /,/) {
            $m =~ s/\s//g;
            $utilities{$users[$i].','.$m} = $currentUtility;
            push @{$preferenceLists{$users[$i]}}, $m;
            $i++;
        }
        $currentUtility--;
        $nPreferences++;
    }
    $utilities{$_} -= $currentUtility for (keys %utilities);
    close(FILE);
    
    system('clear');
    say "";
    for my $user (@users) {
        for my $m (@{$preferenceLists{$user}}) {
            say "U_$user($m) = " . utility($user, $m);
        }
    }
    say "";
    for my $user (@users) {
        say "$user\'s preferences = " . join(',', @{$preferenceLists{$user}});
    }
    
    simulate();
        
    say "#offers = " . (scalar @offerHistory + scalar @offerHistory2) . "\n";
    my $lastOffer = pop @offerHistory;
    $lastOffer =~ /\S+,\S+,(\S+)/;
    my $selectedMovie = $1;
    if (utility($users[0], $selectedMovie) > 0) {
        say "FINAL UTILITIES";
        print "$_ = " . utility($_, $selectedMovie) . " " for (@users);
        say "";
    }
}

main();
