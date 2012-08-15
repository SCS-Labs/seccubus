# ------------------------------------------------------------------------------
# $Id$
# ------------------------------------------------------------------------------
# Seccubus User manipulation perl module. 
# ------------------------------------------------------------------------------

package SeccubusUsers;

use SeccubusRights;
use SeccubusDB;

=head1 NAME $RCSfile: SeccubusUsers.pm,v $

This Pod documentation generated from the module Seccubus_Users gives a list of 
all functions within the module

=cut

@ISA = ('Exporter');

@EXPORT = qw ( 
		get_user_id
		add_user 
	     );

use strict;
use Carp;

sub get_user_id($);
sub add_user($$$);

=head1 User manipulation

=head2 get_user_id
 
This function looks up the numeric user_id based on the username

=over 2

=item Parameters

=over 4

p
=item user - username

=back

=item Checks

None

=back 

=cut 

sub get_user_id($) {
	my $user = shift;
	confess "No username specified" unless $user;

	my $id = sql ( "return"	=> "array",
		       "query"	=> "select id from users where username = ?",
		       "values" => [ $user ],
		     );

	if ( $id ) {
		return $id;
	} else {
		confess("Could not find a userid for user '$user'");
	}
}

=head2 add_user
 
This function adds a use to the users table and makes him member of the all 
group. 

=over 2

=item Parameters

=over 4

=item user - username

=item name - "real" name of the user

=item isadmin - indicates that the user is an admin (optional)

=back

=item Checks

In order to run this function you must be an admin

=back 

=cut 

sub add_user($$$) {
	my $user = shift;
	my $name = shift;
	my $isadmin = shift;

	my ( $id );

	confess "No userid specified" unless $user;
	confess "No naem specified for user $user" unless $name;

	if ( is_admin() ) {
		my $id = sql(	"return"	=> "id",
				"query"		=> "INSERT into users (`username`, `name`) values (? , ?)",
				"values"	=> [$user, $name],
			    );
		#Make sure member of the all group
		sql("return"	=> "id",
		    "query"	=> "INSERT into user2group values (?, ?)",
		    "values"	=> [$id, 2],
	 	   );
		if ( $isadmin ) {
			# Make user meber of the admins group
			sql("return"	=> "id",
			    "query"	=> "INSERT into user2group values (?, ?)",
			    "values"	=> [$id, 1],
			   );
		}
	}
}

# Close the PM file.
return 1;
