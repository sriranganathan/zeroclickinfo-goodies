package DDG::Goodie::ChineseToPinyin;
# ABSTRACT: Get Pinyin of a Chinese string.

use strict;
use utf8;
use DDG::Goodie;
use Lingua::Han::PinYin;

zci answer_type => 'chinese_to_pinyin';
zci is_cached => 1;

triggers startend => 'pinyin', '拼音';


# FROM https://github.com/lilydjwg/winterpy/blob/master/pylib/pinyintone.py

# map (final) constanant+tone to tone+constanant
my %mapConstTone2ToneConst = ('n1' => '1n',
                              'n2' => '2n',
                              'n3' => '3n',
                              'n4' => '4n',
                              'ng1' => '1ng',
                              'ng2' => '2ng',
                              'ng3' => '3ng',
                              'ng4' => '4ng',
                              'r1' => '1r',
                              'r2' => '2r',
                              'r3' => '3r',
                              'r4' => '4r');

# map vowel+vowel+tone to vowel+tone+vowel
my %mapVowelVowelTone2VowelToneVowel = ('ai1' => 'a1i',
                                        'ai2' => 'a2i',
                                        'ai3' => 'a3i',
                                        'ai4' => 'a4i',
                                        'ao1' => 'a1o',
                                        'ao2' => 'a2o',
                                        'ao3' => 'a3o',
                                        'ao4' => 'a4o',
                                        'ei1' => 'e1i',
                                        'ei2' => 'e2i',
                                        'ei3' => 'e3i',
                                        'ei4' => 'e4i',
                                        'ou1' => 'o1u',
                                        'ou2' => 'o2u',
                                        'ou3' => 'o3u',
                                        'ou4' => 'o4u');

# map vowel-number combination to unicode
my %mapVowelTone2Unicode = ('a1' => 'ā',
                           'a2' => 'á',
                           'a3' => 'ǎ',
                           'a4' => 'à',
                           'e1' => 'ē',
                           'e2' => 'é',
                           'e3' => 'ě',
                           'e4' => 'è',
                           'i1' => 'ī',
                           'i2' => 'í',
                           'i3' => 'ǐ',
                           'i4' => 'ì',
                           'o1' => 'ō',
                           'o2' => 'ó',
                           'o3' => 'ǒ',
                           'o4' => 'ò',
                           'u1' => 'ū',
                           'u2' => 'ú',
                           'u3' => 'ǔ',
                           'u4' => 'ù',
                           'v1' => 'ǜ',
                           'v2' => 'ǘ',
                           'v3' => 'ǚ',
                           'v4' => 'ǜ');


# MAIN

handle remainder_lc => sub {
    return if /^\s*$/;
    
    return if /[āáǎàēéěèīíǐìōóǒòūúǔùǜǘǚǜ]/;
    
    my $h2p = new Lingua::Han::PinYin(tone => 1);
    my $result = $h2p->han2pinyin($_);
    $result = ConvertTone($result);
    
    return "Pinyin of $_ is \"$result\"",
        structured_answer => {
        data => {
            title => "$result",
            subtitle => "Pinyin of $_"
        },
        templates => {
            group => 'text'
        }
    };
};


# sub: convert e.g. ni3hao3 to nǐ hǎo

sub ConvertTone{
    print("Before convert tone: @_\n");
    
    # replace "number" to "number " (i.e. add a space after every number)
    my $new = "@_" =~ s/([0-9]+)/$1 /rg;
    
    # trim
    $new = $new =~ s/^\s+|\s+$//rg;
    
    for my $key ( keys %mapConstTone2ToneConst ) {
        #print "$key: $mapConstTone2ToneConst{$key} \n";
        $new = $new =~ s/$key/$mapConstTone2ToneConst{$key}/r;
    }
    for my $key ( keys %mapVowelVowelTone2VowelToneVowel ) {
        #print "$key: $mapVowelVowelTone2VowelToneVowel{$key} \n";
        $new = $new =~ s/$key/$mapVowelVowelTone2VowelToneVowel{$key}/r;
    }
    for my $key ( keys %mapVowelTone2Unicode ) {
        #print "$key: $mapVowelTone2Unicode{$key} \n";
        $new = $new =~ s/$key/$mapVowelTone2Unicode{$key}/r;
    }
    $new = $new =~ s/v/ü/r;
    $new = $new =~ s/V/Ü/r;
    print("After convert tone: $new\n");
    return "$new";
}

1;