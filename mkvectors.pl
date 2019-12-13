#!/usr/bin/perl
use strict;

my @vec;
$vec[1] = "Reset";
$vec[2] = "NMI";
$vec[3] = "HardFault";
$vec[4] = "MemManage";
$vec[5] = "BusFault";
$vec[6] = "UsageFault";
$vec[11] = "SVC";
$vec[12] = "DebugMon";
$vec[14] = "PendSV";
$vec[15] = "SysTick";

my %set = ();

sub parsenum {
    return ($_[0] =~ /^0/) ? (oct $_[0]) : (int $_[0]);
}

for my $line (<>) {
    chomp $line;
    if ($line eq '' or $line =~ /^#/) {
        next;
    } elsif ($line =~ /^vec\s+([0-9a-fx]+)\s+(\w\S*)$/i) {
        my $n = parsenum($1) + 16;
        my $name = $2;
        die "Vector $1 already defined as $vec[$n]" if defined $vec[$n];
        $vec[$n] = $name;
    } elsif ($line =~ /^set\s+(\w+)\s+([0-9a-fx]+)$/i) {
        $set{$1} = $2;
    } else {
        die "Unable to parse line: $line";
    }
}

if (exists $set{bootram}) {
    $set{bootram} = parsenum($set{bootram});
    die "BootRAM overlaps with vectors" if $set{bootram} < (4 * @vec);
    die "BootRAM seems unreasonably high" if $set{bootram} > 4096;
    die "Must set bootram_val if bootram is in use" if !defined $set{bootram};
}

print <<EOF;
/* This file was generated from $ARGV by mkvectors.pl */

.syntax unified
.arch armv7-m
.cpu cortex-m0
.thumb

.section .text.Default_Handler
.type Default_Handler, %function
Default_Handler:
    nop
__uncaught_exception:
    b .
.size Default_Handler, .-Default_Handler

.section .isr_vector, "a", %progbits
.align
.global __isr_vector
.type __isr_vector, %object

__isr_vector:
  .word __stack
EOF

for my $i (1 .. $#vec) {
    printf "\n/* 0x%x */\n", $i * 4;
    if (defined $vec[$i]) {
        print "  .word $vec[$i]_Handler\n";
        print "  .weak $vec[$i]_Handler\n";
        print "  .thumb_set $vec[$i]_Handler, Default_Handler\n";
    } else {
        print "  .word 0\n";
    }
}

if (exists $set{bootram}) {
    my $pos = 4 * @vec;
    printf "\n/* BootRAM at %x */\n", $set{bootram};
    printf "  .skip 0x%x\n", $set{bootram} - $pos if $pos < $set{bootram};
    printf "  .word %s\n", $set{bootram_val};
}

print "\n.size __isr_vector, . - __isr_vector\n";
