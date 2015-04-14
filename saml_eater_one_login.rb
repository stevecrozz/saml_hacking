require 'ruby-saml'

class SamlEaterOneLogin
  def initialize(app_id:)
    @app_id = app_id
  end

  def saml_settings
    return @settings if @settings

    @settings = OneLogin::RubySaml::Settings.new

    @settings.assertion_consumer_service_url = "http://localhost/saml/finalize"
    @settings.issuer                         = 'localhost'
    @settings.idp_sso_target_url             = "https://app.onelogin.com/saml/metadata/#{@app_id}"
    @settings.idp_entity_id                  = "https://app.onelogin.com/saml/metadata/#{@app_id}"
    @settings.idp_sso_target_url             = "https://app.onelogin.com/trust/saml2/http-post/sso/#{@app_id}"
    @settings.idp_slo_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/slo/#{@app_id}"
    @settings.idp_cert_fingerprint           = "A4:8A:B7:40:99:20:ED:FC:DD:B6:38:D9:7B:A5:87:F6:94:4B:E8:CB"
    @settings.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha1"
    @settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    # Optional for most SAML IdPs
    @settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

    # Optional bindings (defaults to Redirect for logout POST for acs)
    @settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    @settings.assertion_consumer_logout_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"

    @settings
  end

  def eat_response(response)
    response = OneLogin::RubySaml::Response.new(response)
    response.settings = saml_settings

    if response.is_valid?
      {
        userid: response.name_id,
        attributes: response.attributes.to_h
      }
    else
      false
    end
  end
end
