package ByObservat::UploadFrom1c::Wsdl;
use Mojo::Base '-base';
use utf8;

# TODO Для 1С требуется, чтоб совпадали названия помеченные как THIS?
# <soap:operation style="document" soapAction="<%= $location_service %>#THIS"/>
# <message name="anketaCntRequest"> <part name="parameters" element="tns:THIS" /> </message>

has 'class';
has 'methods';
has 'location_service';
has 'location_namespace';

sub get_Definitions {
  my ( $self ) = @_;
  my $location = $self->location_namespace;

  return qq|
    <definitions
      xmlns="http://schemas.xmlsoap.org/wsdl/"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
      xmlns:tns="${location}"
      targetNamespace="${location}"
    >
  |;
}

sub get_GroupType {
  my ( $self ) = @_;
  my $class = $self->class;

  return qq|
    <xsd:complexType name="${class}GroupType">
      <xsd:sequence>
        <xsd:element name="${class}Element" type="${class}ElementType" minOccurs="0" maxOccurs="unbounded"/>
      </xsd:sequence>
    </xsd:complexType>
  |;
}

sub get_ResponseIntType {
  return q|
    <xsd:complexType name="ResponseIntType">
      <xsd:sequence>
        <xsd:element name="result" type="xsd:int"/>
      </xsd:sequence>
    </xsd:complexType>
  |;
}

sub get_ResponseUpdateType {
  return q|
    <xsd:complexType name="ResponseUpdateType">
    <xsd:sequence>
      <xsd:element name="result">
        <xsd:sequence>
          <xsd:element name="insert" type="xsd:int"/>
          <xsd:element name="update" type="xsd:int"/>
          <xsd:element name="delete" type="xsd:int"/>
          <xsd:element name="skip" type="xsd:int"/>
          <xsd:element name="message" type="xsd:string"/>
        </xsd:sequence>
      </xsd:element>
    </xsd:sequence>
    </xsd:complexType>
  |;
}

sub get_Messages {
  my ( $self ) = @_;

  my @messages = ();
  foreach my $method ( @{$self->methods} ) {
    push @messages, qq|
      <message name="${method}Request">
        <part name="parameters" element="tns:${method}" />
      </message>
      <message name="${method}Response">
        <part name="ResponseSoapMsg" element="tns:${method}Response" />
      </message>
    |;
  }
  return join "\n", @messages;
}

sub get_PortType {
  my ( $self ) = @_;

  my @operations = ( '<portType name="'.$self->class.'PortType">' );
  foreach my $method ( @{$self->methods} ) {
    # Внутри operation можно документацию <wsdl:documentation>
    push @operations, qq|
	<operation name="${method}">
		<input message="tns:${method}Request" />
		<output message="tns:${method}Response" />
	</operation>
    |;
  }
  push @operations, '</portType>';

  return join "\n", @operations;
}

sub get_Binding {
  my ( $self ) = @_;
  my $location_service = $self->location_service;

  my @operations = ( '<binding name="'.$self->class.'Binding" type="tns:'.$self->class.'PortType">',
                     '<soap:binding style="document" transport="http://schemas.xmlsoap.org/soap/http"/>' );
  foreach my $method ( @{$self->methods} ) {
    push @operations, qq|
	<operation name="${method}">
		<soap:operation style="document" soapAction="${location_service}#${method}"/>
		<input>
			<soap:body use="literal"/>
		</input>
		<output>
			<soap:body use="literal"/>
		</output>
	</operation>
    |;
  };
  push @operations, '</binding>';

  return join "\n", @operations;
}

1;
