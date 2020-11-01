#!/usr/bin/perl
use strict;
use warnings;



sub generate_pem {
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



generate_pem("eph_pubkey.pem", "ciphertext.bin", "iv.bin", "tag.bin", "final.pem");
