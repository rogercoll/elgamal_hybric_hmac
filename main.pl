#!/usr/bin/perl
use strict;
use warnings;
require './key_generation.pl';
require './encryption.pl';

sub decrypt {
	my ($pub, $pri, $iv_file) = @_;
	common_secret($pub, $pri, "common.bin");	
	my ($k1, $k2) = extract_secure_key("common.bin");
	print $k2 . "\n";
	my $iv = `cat $iv_file | xxd -p`;
	chomp($iv);
	compute_tag($k2, $iv_file, "decrypt/ciphertext.bin", "decrypt/tmptag.bin");
	my $tag1 = `xxd -p decrypt/tag.bin`;
	my $tag2 = `xxd -p decrypt/tmptag.bin`;
	die "Wrong tag! Could not authenticate the source\n" if ($tag1 ne $tag2);
	print "Decrypting data...\n";
	decrypt_file($k1, $iv, "decrypt/ciphertext.bin");
}

sub encrypt {
	my ($pub, $pri) = @_;
	common_secret($pub, $pri, "common.bin");
	my ($k1, $k2) = extract_secure_key("common.bin");
	encrypt_file($k1, "data_to_encript.txt");
	compute_tag($k2, "iv.bin", "ciphertext.bin", "tag.bin");
}

sub create_keys {
	create_params("params.pem");
	create_keypair("alice", "params.pem");
	create_keypair("eph", "params.pem");
}



#create_keys();
#encrypt("alice_pubkey.pem", "eph_pkey.pem");
#Decrypt file that has been encrypted with eph_pkey and commond secret has been generated with alice_pubkey.pem
decrypt("decrypt/cert.pem", "test_david/alice_pkey.pem", "decrypt/iv.bin");
