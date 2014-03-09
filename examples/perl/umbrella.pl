#!/usr/bin/perl

require 5.6.1;

use strict;
use warnings;

use Devel::Cover::DB;
use Config;
use File::Spec;
use File::Find ();
use File::Path;
use Getopt::Long;

my $Options = 
{
    add_uncoverable_point => [],
    annotation => [],
    coverage => [],
    delete => undef,
    gcov => $Config{gccversion},
    ignore => [],
    ignore_re => [],
    launch => 0,
    make => $Config{make},
    report => "",
    report_c0 => 75,
    report_c1 => 90,
    report_c2 => 100,
    select => [],
    select_re => [],
    summary => 1,
    uncoverable_file => [".uncoverable", glob("~/.uncoverable")],
};

sub main
{
    my $dbname = File::Spec->rel2abs("cover_db");
    die "Can't open database $dbname\n"
        if !-d $dbname;

    $Options->{outputdir} = File::Spec->rel2abs($dbname);
    mkpath($Options->{outputdir}) unless -d $Options->{outputdir};

    my $db = Devel::Cover::DB->new
    (
        db => $dbname,
        uncoverable_file => $Options->{uncoverable_file}, 
    );

    $db = $db->merge_runs;
    $db->add_uncoverable($Options->{add_uncoverable_point});
    $db->delete_uncoverable($Options->{delete_uncoverable_point});
    $db->clean_uncoverable
        if $Options->{clean_uncoverable_points};
    $db->calculate_summary(map { $_ => 1 } @{$Options->{coverage}});

    my $lines = "";
    
    # Loop through the coverage and output for each file.
    for my $file (sort keys %{$db->{summary}})
    {
        my $line = "$file;";

        my $numbers = "";
        for my $n (sort keys %{$db->cover->{$file}->{statement}})
        {
            my $hits = $db->cover->{$file}->{statement}->{$n}->[0]->[0];
            my $errs = $db->cover->{$file}->{statement}->{$n}->[0]->[1];
            
            if ($hits > 0 && length($errs // '') == 0)
            {
                $numbers .= $n . ",";
            }
        }
        
        chop($numbers);
        $line .= $numbers . ";";
    
        $numbers = "";
        for my $n (sort keys %{$db->cover->{$file}->{statement}})
        {
            my $hits = $db->cover->{$file}->{statement}->{$n}->[0]->[0];
            my $errs = $db->cover->{$file}->{statement}->{$n}->[0]->[1];

            if ($hits > 0 && length($errs // '') > 0)
            {
                $numbers .= $n . ",";
            }
        }

        chop($numbers);
        $line .= $numbers . ";";

        $numbers = "";
        for my $n (sort keys %{$db->cover->{$file}->{statement}})
        {
            my $hits = $db->cover->{$file}->{statement}->{$n}->[0]->[0];
            my $errs = $db->cover->{$file}->{statement}->{$n}->[0]->[1];

            if ($hits == 0 && length($errs // '') == 0)
            {
                $numbers .= $n . ",";
            }
        }

        chop($numbers);
        $line .= $numbers . ";";
        $lines .= $line . "\n";
        print $lines;
    }

    # Write to our coverage file.
    open(MYFILE, ">.umbrella-coverage");
    print MYFILE $lines;
    close(MYFILE);
}

main
