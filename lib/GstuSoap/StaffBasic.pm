package GstuSoap::StaffBasic;
use strict;
use warnings;
use utf8;

use base 'ByObservat::UploadFrom1c';
use ByObservat::UploadFrom1c::EnabledSubs::GetCount;
use ByObservat::UploadFrom1c::EnabledSubs::UpdateAllRecords;
use ByObservat::UploadFrom1c::EnabledSubs::UpdateWithoutDeletingRecords;

my @methods_for_wsdl = qw/ getCount updateAllRecords updateWithoutDeletingRecords /;

use EsapCommon::DB;

sub _get_default_dbh {
  # TODO кто и когда будет отключать этот $dbh?
#  return undef;
  return EsapCommon::DB->get_dbh( 'asu-soap' ); # TODO
}

sub new {
  my ( $self, $params, $soap_config ) = @_;

# TODO  $soap_config //= EsapCommon::Config->get_hash(qw/ soap_staff_basic_server soap_staff_basic_port /);

  $params = {
#    'uid' => Cfg::get->{uid_soap_asu_staff}, # TODO uid из другого места брать?
    'uid' => 0,
    'to' => {
      'table_name' => 'staff_basic',
      'table_key' => 'MY_NOM',
      'table_fields' => [ qw/FAM IMY OTCH MY_NOM PDR DLG1/ ],
#           all_fields: [ qw/FAM IMY OTCH MY_NOM PDR DLG1 NAZVAN TP_ID status teacher/ ];
    },
    'wsdl' => {
      'class' => 'StaffBasic', # TODO
      'methods' => [ @methods_for_wsdl ],
      'location_service'   => 'http://'.$soap_config->{soap_staff_basic_server}.':'.$soap_config->{soap_staff_basic_port}.'/StaffBasic',
      'location_namespace' => 'http://'.$soap_config->{soap_staff_basic_server}.':'.$soap_config->{soap_staff_basic_port}.'/StaffBasic',
    },
    %{ $params // {} },
  };

  if( ! defined $params->{'to'}->{'dbh'} and defined $params->{'dbh'} ) {
    $params->{'to'}->{'dbh'} = delete $params->{'dbh'};
  }

  unless( defined $params->{'to'}->{'dbh'} ) {
    $params->{'to'}->{'dbh'} = $self->_get_default_dbh;
  }

  $self = $self->SUPER::new( $params );

  return $self;
}

sub get_wsdl_Service {
  my ( $self ) = @_;

  return q{
    <service name="StaffBasicService">
      <port name="} . $self->wsdl->class . q{" binding="tns:} . $self->wsdl->class . q{Binding">
        <soap:address location="} . $self->wsdl->location_service . q{"/>
      </port>
    </service>
  };
}

sub get_wsdl_Types {
  my ( $self ) = @_;

  my $location_namespace = $self->wsdl->location_namespace;

  # TODO необязательный параметр type="xsd:NULL" вместо type="xsd:string" в name="getCount"?
  return q{
    <types>
      <xsd:schema targetNamespace="} . $self->wsdl->location_namespace . q{">
	<xsd:element name="getCount" type="xsd:string" minOccurs="0"/>
	<xsd:element name="getCountResponse" type="xsd:ResultIntType" minOccurs="1"/>
	<xsd:element name="updateAllRecords" type="xsd:StaffBasicGroupType" minOccurs="1"/>
	<xsd:element name="updateAllRecordsResponse" type="xsd:ResultUpdateType" minOccurs="1"/>
	<xsd:element name="updateWithoutDeletingRecords" type="xsd:StaffBasicGroupType" minOccurs="1"/>
	<xsd:element name="updateWithoutDeletingRecordsResponse" type="xsd:ResultUpdateType" minOccurs="1"/>}
	. $self->wsdl->get_GroupType
	. $self->get_wsdl_ElementType
	. $self->wsdl->get_ResponseIntType
	. $self->wsdl->get_ResponseUpdateType
	. q{
      </xsd:schema>
    </types>
  };
}

sub get_wsdl_ElementType {
  my ( $self ) = @_;

  return q{
  <xsd:complexType name="StaffBasicElementType">
    <xsd:sequence>
      <xsd:element name="FAM">
        <xsd:simpleType>
          <xsd:restriction base='xsd:string'>
            <xsd:maxLength value='50'/>
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:element>
      <xsd:element name="IMY">
        <xsd:simpleType>
          <xsd:restriction base='xsd:string'>
            <xsd:maxLength value='50'/>
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:element>
      <xsd:element name="OTCH">
        <xsd:simpleType>
          <xsd:restriction base='xsd:string'>
            <xsd:maxLength value='50'/>
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:element>
      <xsd:element name="MY_NOM">
        <xsd:simpleType>
          <xsd:restriction base='xsd:string'>
            <xsd:maxLength value='14'/>
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:element>
      <xsd:element name="PDR">
        <xsd:simpleType>
          <xsd:restriction base='xsd:string'>
            <xsd:maxLength value='128'/>
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:element>
      <xsd:element name="DLG1">
        <xsd:simpleType>
          <xsd:restriction base='xsd:string'>
            <xsd:maxLength value='128'/>
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:element>
    </xsd:sequence>
  </xsd:complexType>
  };
}

1;
