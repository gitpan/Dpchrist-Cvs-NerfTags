#######################################################################
# $Id: Makefile.PL,v 1.5 2010-03-26 04:12:40 dpchrist Exp $
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
# USA.
#######################################################################

use 5.010000;
use ExtUtils::MakeMaker;

use Dpchrist::Module::MakefilePL (
    -mcpani		=> $ENV{CPAN_AUTHORID},
    -pod2html	 	=> [qw(
	bin/cvsnerftags
    	lib/Dpchrist/Cvs/NerfTags.pm
    )],
    -release		=> $ENV{RELEASE_ROOT},
);

WriteMakefile(
    NAME		=> 'Dpchrist::Cvs::NerfTags',
    VERSION_FROM	=> 'lib/Dpchrist/Cvs/NerfTags.pm',
    PREREQ_PM		=> {
	Capture::Tiny		=> 0,
	Dpchrist::Debug		=> 1.036,
	Dpchrist::Module	=> 1.016,
	Dpchrist::ShellScript	=> 1.002,
	'feature'		=> 0,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/Cvs/NerfTags.pm',
    AUTHOR		=>
	'David Christensen dpchrist@holgerdanske.com',
    EXE_FILES           => ['./bin/cvsnerftags'],
    clean		=> {
	FILES => q( *~tmp */*~tmp* Dpchrist* cvsnerftags* ),
    },
);

#######################################################################
