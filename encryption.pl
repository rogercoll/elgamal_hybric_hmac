###!/usr/bin/perl
use strict;
use warnings;


sub common_secret {
	my ($pub,$priv,$common_file) = @_;
	print "Deriving common secret using $pub as the long-term public key and $priv as the ephemeral private key\n";
 	`openssl pkeyutl -inkey $priv -peerkey $pub -derive -out $common_file | openssl dgst -sha256 -binary > comm.bin`;
}

sub extract_secure_key {
	my ($common_file) = @_;
	my $key1 = `head -c 16 comm.bin | xxd -p`;
	my $key2 = `tail -c 16 comm.bin | xxd -p`;
	chomp($key1);
	chomp($key2);
	return $key1, $key2;
}

sub encrypt_file {
	my ($k1,$file) = @_;
	my $iv = `openssl rand -hex 16`;
	chomp($iv);
	open(FH, '>', "iv.bin") or die $!;
	print FH $iv;
	`openssl enc -aes-128-cbc -K $k1 -iv $iv -in $file -out ciphertext.bin`;
}

sub decrypt_file {
	my ($k1, $iv, $file) = @_;
	`openssl enc -d -aes-128-cbc -K $k1 -iv $iv -in $file -out decrypted.bin`;
}


sub compute_tag {
	my ($k2, $iv, $cipher, $file) = @_;
	`cat $iv $cipher | openssl dgst -binary -sha256 -hmac $k2 > $file`
}

1;
