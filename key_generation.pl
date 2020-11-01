#!/usr/bin/perl
use strict;
use warnings;

sub create_params {
	my $file_name = shift;
	print "Generating DH parameters file...\n";	
	`openssl genpkey -genparam -algorithm dh -pkeyopt dh_rfc5114:3 -out $file_name`;
	print "Params file name: $file_name\n";	
}

sub create_keypair {
	my ($name, $params_file) = @_;
	print "Creating key pair for $name given the $params_file as the DH parameters file...\n";
	my $keyName = $name . "_pkey.pem";
	my $pubName = $name . "_pubkey.pem";
	`openssl genpkey -paramfile $params_file -out $keyName`;
	`openssl pkey -in $keyName -pubout -out $pubName`;
}

create_params("params.pem");
create_keypair("alice", "params.pem");
create_keypair("eph", "params.pem");
