#!/usr/bin/perl -w
# virt-rescue
# Copyright (C) 2009 Red Hat Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

use warnings;
use strict;

use Sys::Guestfs;
use Sys::Guestfs::Lib qw(open_guest);
use Pod::Usage;
use Getopt::Long;
use Locale::TextDomain 'libguestfs';

=encoding utf8

=head1 NAME

virt-rescue - Run a rescue shell on a virtual machine

=head1 SYNOPSIS

 virt-rescue [--options] domname

 virt-rescue [--options] disk.img [disk.img ...]

=head1 DESCRIPTION

virt-rescue gives you a rescue shell and some simple recovery tools
which you can use on a virtual machine disk image.

After running virt-rescue, what you see under C</> is the recovery
appliance.  You must mount the virtual machine's filesystems by hand,
eg:

 # lvs
 LV      VG        Attr   LSize   Origin Snap%  Move Log Copy%  Convert
 lv_root vg_f11x64 -wi-a-   8.83G
 lv_swap vg_f11x64 -wi-a- 992.00M
 # mount /dev/vg_f11x64/lv_root /sysroot
 # ls /sysroot

B<Note> that the virtual machine must not be powered on when you use
this tool.  Doing so will probably result in disk corruption in the
VM.  However if you use the I<--ro> (read only) option, then you can
attach a shell to a running machine, but the results might be strange
or inconsistent.

This tool is just designed for quick interactive hacking on a virtual
machine.  For more structured access to a virtual machine disk image,
you should use L<guestfs(3)>.  To get a structured shell, use
L<guestfish(1)>.

=head1 OPTIONS

=over 4

=cut

my $help;

=item B<--help>

Display brief help.

=cut

my $version;

=item B<--version>

Display version number and exit.

=cut

my $uri;

=item B<--connect URI> | B<-c URI>

If using libvirt, connect to the given I<URI>.  If omitted, then we
connect to the default libvirt hypervisor.

If you specify guest block devices directly, then libvirt is not used
at all.

=cut

my $readonly;

=item B<--ro> | B<-r>

Open the image read-only.

=back

=cut

GetOptions ("help|?" => \$help,
            "version" => \$version,
            "connect|c=s" => \$uri,
	    "ro|r" => \$readonly,
    ) or pod2usage (2);
pod2usage (1) if $help;
if ($version) {
    my $g = Sys::Guestfs->new ();
    my %h = $g->version ();
    print "$h{major}.$h{minor}.$h{release}$h{extra}\n";
    exit
}

pod2usage (__"virt-rescue: no image or VM names rescue given")
    if @ARGV == 0;

my @args = (\@ARGV);
push @args, address => $uri if $uri;
push @args, rw => 1 unless $readonly;
my $g = open_guest (@args);

$g->set_direct (1);
$g->set_append ("guestfs_rescue=1");

$g->launch ();

exit 0;

=head1 SEE ALSO

L<guestfs(3)>,
L<guestfish(1)>,
L<virt-cat(1)>,
L<Sys::Guestfs(3)>,
L<Sys::Guestfs::Lib(3)>,
L<Sys::Virt(3)>,
L<http://libguestfs.org/>.

=head1 AUTHOR

Richard W.M. Jones L<http://et.redhat.com/~rjones/>

=head1 COPYRIGHT

Copyright (C) 2009 Red Hat Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
