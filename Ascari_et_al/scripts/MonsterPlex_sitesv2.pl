#!/usr/bin/perl

die "Usage: perl MonsterPlex_sites.pl <MAP> <SITES-LIST> <SNPs-DIR>\n" if @ARGV != 3;

# Create hash of 70-15 coordinate to B71 coordinate conversions

open(MAP, $ARGV[0]);

while($M = <MAP>) {

  chomp($M);

  my ($ref, $rs, $test, $ts) = split(/\t/, $M);

  $ref =~ s/.+?(\d)$/$1/;

  $test =~ s/.+?(\d)$/$1/;

  @{$MapHash{$ref}{$rs}} = ($test, $ts);

}

close MAP;


# Read B71 sequences to a hash (this block not actually utilized in the version)

$eol = $/;

$/ = undef;

open(B71, "B71v2sh_masked.fasta") || die "B71 reference?\n";

$B71 = <B71>;

@B71 = split(/>/, $B71);

shift @B71;

foreach $SeqEntry (@B71) {

  ($ID, $Seq) = split(/\n/, $SeqEntry);

  $ID =~ s/.+?(\d)/$1/;

  $B71hash{$ID} = $Seq;

#  print "$ID\n$Seq\n";

}

close B71;

$/ = $eol;


# Read MonsterPlex sites on 70-15 genome and map to B71v2sh

# store ref nucl 

## the next block works perfectly

# sub REF_HASH { remove # when subroutine activated

open(SITES, $ARGV[1]) || die "Sites file\n?";

while($S = <SITES>) {

  chomp($S);

  ($chr, $ncbi, $site, $geneid) = split(/\t| +/, $S);

  $chr =~ s/.+(\d)$/$1/;

  $site-- ; # make up for error in MonsterPlex sites list

  my ($testchr, $testsite) = @{$MapHash{$chr}{$site}};

  $refnucl = substr($B71hash{$testchr}, $testsite-1, 1);

#  print "{$geneid}{$testchr}{$testsite} = $refnucl\n"; # check list of genes hits correct ref bases

  @{$GetNucl{$geneid}} = ($testchr, $testsite, $refnucl);

  $InterestingSites{$testchr}{$testsite} = $geneid;

}

close SITES;

%B71hash = undef;

# }  remove # when subroutine activated

###
# Check if MP sites are polymorphic in test strains and hash the results
###

# note: this block does not yet check if SNP site is in a cryptic repeat

opendir(SNP, $ARGV[2]);

@Files = readdir(SNP);

foreach $file (@Files) {

  next if $file !~ /out$/;

  ($strain = $file) =~ s/.+_v_(.+)_out/$1/;

#  print "$strain\n";  # ID capture is functional 
 
  $StrainHash{$strain} = 1;

  open(F, "$ARGV[2]/$file") || die "Can't open SNPs outfile\n";

  while($F = <F>) {

    chomp($F);

    @SNPs = split(/\t/, $F);

    $SNPs[0] =~ s/.+?(\d)$/$1/;

    # check if SNP position coincides with one of the targeted sites

    if(exists($InterestingSites{$SNPs[0]}{$SNPs[2]})) {

      $mgg = $InterestingSites{$SNPs[0]}{$SNPs[2]};

      # check if there is an indel at the site in question

      if($SNPs[5] eq '-') {
 
        $SNPsHash{$strain}{$mgg} = '-';

      }

      # otherwise record the SNP at the site

      else {

        $SNPsHash{$strain}{$mgg} = $SNPs[5]

      }

    }

  }

}    

closedir SNP;


# Look at alignment strings and check if target SNP sites were in a unique alignment

# if not, write site as '-';

# if yes, check the SNPsHash to see if the sites were recorded as polymorphic

# and then, if not, write the reference base at that site

# "non-polymorphic" sites were interrogated in a B71 alignment

foreach $strain (sort {$a cmp $b} keys %StrainHash) {

  open(ALIGN, "B71v2_align/B71v2sh\.$strain"."_alignments") || die "no alignfile\n";

  while($A = <ALIGN>) {

    chomp($A);

    my ($ID, $alignString) = split(/\t/, $A);

    $ID =~ s/.+?(\d)/$1/;

    #print "$ID\n";

    $AlignHash{$ID} = $alignString

  }

  close ALIGN;

  # Loop through sites to interrogate

  foreach my $geneid (sort {$a cmp $b} keys %GetNucl) {

    unless(exists($SNPsHash{$strain}{$geneid})) {

      ($testchr, $testsite, $refnucl) = @{$GetNucl{$geneid}};
      
      if(substr($AlignHash{$testchr}, $testsite-1, 1) == 1) {

        $SNPsHash{$strain}{$geneid} = ${$GetNucl{$geneid}}[2]  # assign ref nucleotide

      }

      else {

        $SNPsHash{$strain}{$geneid} = '-' # assign gap

      }

    }

  }

}

foreach my $strain (sort {$a cmp $b} keys %StrainHash) {

  foreach $mgg (sort {$a cmp $b} keys %{$SNPsHash{$strain}}) {

    $genotype .= $SNPsHash{$strain}{$mgg}

  }

  print ">$strain\n$genotype\n";

  $genotype = ''

}


