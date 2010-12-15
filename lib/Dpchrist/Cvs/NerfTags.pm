#######################################################################
# $Id: NerfTags.pm,v 1.15 2010-12-15 00:55:13 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::Cvs::NerfTags;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    cvsnerftags
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = sprintf "%d.%03d", q$Revision: 1.15 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use constant			DEBUG => 0;

use Carp;
use Cwd;
use Data::Dumper;
use Dpchrist::Debug		qw( :all );
use File::Find;
use File::Spec::Functions	qw( :ALL );
use File::Temp			qw( tempfile );

#######################################################################
# globals:
#----------------------------------------------------------------------

$Data::Dumper::Sortkeys = 1;

our %opt = (			# options
    -help		=> 0,
    -man		=> 0,
    -quiet		=> 0,
    -keep_orig		=> 0,
    -timeout		=> 10,		# seconds
    -verbose		=> 0,
);

#######################################################################

=head1 NAME

Dpchrist::Cvs::NerfTags - disable RCS/CVS tags in working files

=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.15 $.


This is alpha test level software
and may change or disappear at any time.


=cut

#######################################################################
# private subroutines:
#----------------------------------------------------------------------

sub _wanted
{
    ddump('entry', [\@_], [qw(*_)]) if DEBUG;

    ##### relative should work, but I keep forgeting that File::Find
    ##### changed cwd before calling wanted()...
    my $f = rel2abs($_);

    if (-d $f) {
	print "$0: '$f' is a directory -- skipping\n"
	    if $opt{-verbose};
	goto done;
    }

    if ($f =~ /\-orig$/) {
	print "$0: '$f' leftover from previous run -- skipping\n"
	    if $opt{-verbose};
	goto done;
    }

    ddump([$f], [qw(f)]) if DEBUG;
    dprint (-f $f ? 'is' : 'is not'), "a plain file\n" if DEBUG;
    dprint (-T $f ? 'is' : 'is not'), "a text file\n" if DEBUG;
    unless (-f $f && -T $f) {
	print "$0: '$f' is not a plain text file -- skipping\n"
	    if $opt{-verbose};
	goto done;
    }

    open(my $in, '<', $f)
	or confess "ERROR opening file '$f' for reading: $!";

    my ($out, $tmp) = tempfile();
    confess "ERROR creating temporary file for writing: $!"
	unless $tmp;

    my $n = 0;
    while(<$in>) {
	if ( s/\$(Author.*)\$/_$1_/g
	  || s/\$(Date.*)\$/_$1_/g
	  || s/\$(Header.*)\$/_$1_/g
	  || s/\$(Id.*)\$/_$1_/g
	  || s/\$(Name.*)\$/_$1_/g
	  || s/\$(Locker.*)\$/_$1_/g
	  || s/\$(Log.*)\$/_$1_/g
	  || s/\$(RCSfile.*)\$/_$1_/g
	  || s/\$(Revision.*)\$/_$1_/g
	  || s/\$(Source.*)\$/_$1_/g
	  || s/\$(State.*)\$/_$1_/g
	) {
	    print "$File::Find::name: $_"
		unless $opt{-quiet};
	    $n++;
	}
	print $out $_;
    }

    close($out)
	or confess "ERROR closing temporary file '$tmp': $!";

    close($in)
	or confess "ERROR closing file '$f': $!";

    if ($n) {
	if ($opt{-keep_orig}) {

	    my $g = $f . '-orig';
	    confess "file '$g' already exists"
		if -e $g;
	    print "$0: renaming '$f' to '$g'\n"
		if $opt{-verbose};
	    rename($f, $g)
		or confess "ERROR renaming file '$f' to '$g': $!";
	}
	else {
	    print "$0: deleting '$f'\n"
		if $opt{-verbose};
	    unlink($f)
		or confess "ERROR deleting file '$f': $!";
	}

	print "$0: writing '$f'\n"
	    if $opt{-verbose};
	rename($tmp, $f)
	    or confess "ERROR renaming file '$tmp' to '$f': $!";
    }
    else {
	unlink($tmp)
    	    or confess "ERROR unlinking file '$tmp': $!";
    }

  done:
    dprint "returning\n" if DEBUG;
    return;
}

#######################################################################

=head2 SUBROUTINES

=head3 cvsnerftags

    cvsnerftags LIST

Disable RCS/CVS tags in files.

=cut

#----------------------------------------------------------------------
    
sub cvsnerftags
{
    ddump('entry', [\@_], [qw(*_)]) if DEBUG;


    ### process arguments:

    confess 'Required argument LIST missing' unless 0 < @_;

    foreach (@_) {
	confess "Path '$_' does not exist" unless -e $_;
    }


    ### process files:

    find(\&_wanted, @_);

    
    ### done:

    ddump('returning 1') if DEBUG;
    return 1;
}

#######################################################################
# end of code:
#----------------------------------------------------------------------

1;
__END__

#######################################################################

=head2 EXPORT

None by default.

All of the subroutines may be imported by using the ':all' tag:

    use Dpchrist::Cvs::NerfTags    qw( :all );


=head1 INSTALLATION

Old school:

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install

Minimal:

    $ cpan Dpchrist::Cvs::NerfTags
    
Complete:

    $ cpan Bundle::Dpchrist

The following warnings should not prevent installation:


=head2 PREREQUISITES

See Makefile.PL in the source distribution root directory.


=head1 SEE ALSO

    cvsnerftags(1)


=head1 AUTHOR

David Paul Christensen  dpchrist@holgerdanske.com


=head1 COPYRIGHT AND LICENSE

Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
USA.

=cut

#######################################################################
