#!/usr/bin/perl
use strict;
use warnings;
require './key_generation.pl';
require './encryption.pl';

sub decrypt {
	common_secret("eph_pubkey.pem", "alice_pkey.pem", "common.bin");	
	my ($k1, $k2) = extract_secure_key("common.bin");
	my $iv = `cat iv.bin`;
	decrypt_file($k1, $iv, "ciphertext.bin");
}

create_params("params.pem");
create_keypair("alice", "params.pem");
create_keypair("eph", "params.pem");

common_secret("alice_pubkey.pem", "eph_pkey.pem", "common.bin");
my ($k1, $k2) = extract_secure_key("common.bin");
encrypt_file($k1, "data_to_encript.txt");
compute_tag($k2, "iv.bin", "ciphertext.bin");


decrypt();
