### //////////////////////////////////////////////////////////////////////////
#
#	TOP
#

=head1 NAME

SML::Block - Content::Block using SIMPLIFIED MARKUP LANGUAGE

=cut

#------------------------------------------------------
# 2004/05/13 12:03 - $Date: 2004/05/13 21:04:19 $
# (C) Daniel Peder & Infoset s.r.o., all rights reserved
# http://www.infoset.com, Daniel.Peder@infoset.com
#------------------------------------------------------

###																###
###	this document is edited with tabs having only 4 chars width ###
###																###

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: package
#

	package SML::Block;


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: version
#

	use vars qw( $VERSION $VERSION_LABEL $REVISION $REVISION_DATETIME $REVISION_LABEL $PROG_LABEL );

	$VERSION           = '0.10';
	
	$REVISION          = (qw$Revision: 1.2 $)[1];
	$REVISION_DATETIME = join(' ',(qw$Date: 2004/05/13 21:04:19 $)[1,2]);
	$REVISION_LABEL    = '$Id: Block.pm_rev 1.2 2004/05/13 21:04:19 root Exp root $';
	$VERSION_LABEL     = "$VERSION (rev. $REVISION $REVISION_DATETIME)";
	$PROG_LABEL        = __PACKAGE__." - ver. $VERSION_LABEL";

=pod

 $Revision: 1.2 $
 $Date: 2004/05/13 21:04:19 $

=cut


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: debug
#

	use vars qw( $DEBUG ); $DEBUG=0;
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: constants
#

	# use constant	name		=> 'value';
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: modules use
#

	require 5.005_62;

	use strict                  ;
	use warnings                ;
	
	use	SML::Parser				;
	use	SML::Builder			;
	use	SML::Template			;
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: methods
#

=head1 METHODS

=over 4

=cut



### ##########################################################################

=item	new

 $sml = SML::Block->new();
 
=cut

### --------------------------------------------------------------------------
sub		new
### --------------------------------------------------------------------------
{
	my( $proto ) = @_;
	bless {}, ref( $proto ) || $proto;
}



### ##########################################################################

=item	parse ( $sml )

Initialize the sml data. There should be SML data optionally
separated into some sections. Beginings of sections are marked by section
markers:

 <!section section_name other="1" parameters="2">

where B<!section> is mandatory word, B<section_name> is replaced by the name 
of the section and the other parameters could be whathever You want, however 
currently ignored, are reserved for future use for content type description, 
dynamical source definition etc...

Unmarked parts are stored in section named '_'.

Multiple sections are concatenated into one final section data. 

=cut

### --------------------------------------------------------------------------
sub		parse
### --------------------------------------------------------------------------
{
	my( $self, $sml )=@_;
	
		die "invalid sml data reference" if ref($sml) and ref($sml) ne 'ARRAY'; # very trivial check
	
		$self->{sml}	= SML::Parser->parse( $sml ) if !ref($sml); # string representation
	my	$items			= $self->{sml};
	my	$section_name	= '_'; # default section
	my	$section		= $self->{section} = {};
	my	$f_drop_blanks	= 1;	# flag: set to drop blanks,whitespaces,etc... around section or element boundary
	for	my $item	(@$items)
	{
		if(	$item->[0] eq 'E' and $item->[1] eq '!' and lc($item->[2]) eq 'section' and  $item->[3] =~ /([\w\.\-]+)/)
		{
			# found new section marker: <!section SomeSectionName ... >

			$section_name = $1;
			$f_drop_blanks	= 1;	# drop blanks next to this section marker
			next;
		}
		elsif(	$f_drop_blanks and ( $item->[0] eq 'T' ) and ( $item->[1] =~ /^\s*$/os ))
		{
			# here are the blanks dropped
			
			next;
		}
		
		$f_drop_blanks	= 0;	# once we are here, the blanks are behind us
		
		# push @{$section->{$section_name}}, $item;
		$self->add_section_data( $section_name, $item );
	}

}


### ##########################################################################

=item	add_section_data ( $section_name, $data )

Add single or multiple items into specified section.
B<$data> should be single SML item or arrayref of items.

=cut

### --------------------------------------------------------------------------
sub		add_section_data
### --------------------------------------------------------------------------
{
	my( $self, $section_name, $data )=@_;
	
	if( ref( $data->[0] )) # if there is arrayref item as 1st element, then it is array of items
	{
		push @{$self->{section}{$section_name}}, @$data;
	}
	else
	{
		push @{$self->{section}{$section_name}}, $data;
	}

}



### ##########################################################################

=item	get_section_arrayref ( $section_name )

Get section sml items as arrayref.

=cut

### --------------------------------------------------------------------------
sub		get_section_arrayref
### --------------------------------------------------------------------------
{
	my( $self, $section_name )=@_;
	$self->{section}{$section_name}
}


### ##########################################################################

=item	get_section_sml ( $section_name )

Get section as plain sml text data.

=cut

### --------------------------------------------------------------------------
sub		get_section_sml
### --------------------------------------------------------------------------
{
	my( $self, $section_name )=@_;
	SML::Builder->build( $self->{section}{$section_name} )
}


### ##########################################################################

=item	get_sections_names ( * )

Get names of all sections within block. In array context as array, otherwise
as arrayref.

=cut

### --------------------------------------------------------------------------
sub		get_sections_names
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	wantarray ? keys( %{$self->{section}} ) : \keys( %{$self->{section}} );

}



### ##########################################################################

=item	feed_template ( $template )

Feed block data using parsed|unparsed sml template.

=cut

### --------------------------------------------------------------------------
sub		feed_template
### --------------------------------------------------------------------------
{
	my( $self, $template )=@_;
	
	die "invalid template data type" if ref($template) and ref($template) ne 'SML::Template';
	
	unless( ref $template )
	{
		my	$temp_template		= new SML::Template(); 
			$temp_template->parse( $template );
			$template			= $temp_template;
	}

	for my $section_name ( $self->get_sections_names )
	{
		my $token_name	= $section_name;
		my $token_value	= $self->get_section_sml( $section_name );
		$template->set_token_value( $token_name, $token_value );
	}

	$template->build();
}







=back

=cut


1;

__DATA__

__END__

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: TODO
#

=head1 TODO	


=cut
