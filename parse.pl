#!/usr/bin/perl
use strict;
use warnings;



sub generate_pem {
	print "Generating file with public key, cipher, iv and tag...\n";
	my ($key, $cipher, $iv, $tag, $output_file) = @_;
	open(FH, '>', $output_file) or die $!;
	my $okey = `cat $key`;
	print FH $okey;
	print FH "-----BEGIN AES-128-CBC CIPHERTEXT-----\n";
	my $b64c = `base64 $cipher`;
	print FH $b64c;
	print FH "-----END AES-128-CBC CIPHERTEXT-----\n";
	print FH "-----BEGIN IV-----\n";
	my $b64iv = `base64 $iv`; 
	print FH $b64iv;
	print FH "-----END IV-----\n";
	print FH "-----BEGIN SHA256-HMAC TAG-----\n";
	my $b64tag = `base64 $tag`;
	print FH $b64tag;
	print FH "-----END SHA256-HMAC TAG-----\n";
}

sub parse {
	print "Parsing PEM file, parsed files will be placed in decrypt/ directory\n";
	my ($file) = @_;
	`awk '
  split_after == 1 {n++;split_after=0}
  /-----END/ {split_after=1}
  {print > "decrypt/cert" n ".pem"}' < $file`;
  	my $cipher = `tail -n +2 decrypt/cert1.pem | head -n -1 | base64 -d`;
  	my $iv = `tail -n +2 decrypt/cert2.pem | head -n -1 | base64 -d`;
  	my $tag = `tail -n +2 decrypt/cert3.pem | head -n -1 | base64 -d`;
	open(FH, '>', "decrypt/ciphertext.bin") or die $!;
	print FH $cipher;
	open(FH, '>', "decrypt/iv.bin") or die $!;
	print FH $iv;
	open(FH, '>', "decrypt/tag.bin") or die $!;
	print FH $tag;
	`rm decrypt/cert?.pem`;
}

my $file = $ARGV[0];
if (defined $file) {
	parse("final.pem");
} else {
	generate_pem("eph_pubkey.pem", "ciphertext.bin", "iv.bin", "tag.bin", "final.pem");
}
