Feature: Deliveries

  Scenario: Unauthorized to create deliveries
    When I add "Content-Type" header equal to "application/ld+json"
    And I add "Accept" header equal to "application/ld+json"
    And I send a "POST" request to "/api/deliveries" with body:
      """
      {
        "pickup": {
          "address": "24, Rue de la Paix",
          "doneBefore": "tomorrow 13:00"
        },
        "dropoff": {
          "address": "48, Rue de Rivoli",
          "doneBefore": "tomorrow 13:30"
        }
      }
      """
    Then the response status code should be 401
    And the response should be in JSON
    And print last response
    And the JSON should match:
      """
      {
        "error":"access_denied",
        "error_description":"OAuth2 authentication required"
      }
      """

  @debug
  Scenario: Create delivery with OAuth Client Credentials
    # Given the fixtures file "stores.yml" is loaded
    Given there is a OAuth client
    # And the user "bob" is loaded:
    #   | email      | bob@coopcycle.org |
    #   | password   | 123456            |
    And the HTTP client is authenticated via OAuth Client Credentials
    # And the store with name "Acme" belongs to user "bob"
    # And the store with name "Acme" is authenticated as "bob"
    When I add "Content-Type" header equal to "application/ld+json"
    And I add "Accept" header equal to "application/ld+json"
    And I send a "POST" request to "/api/deliveries" with body:
      """
      {
        "pickup": {
          "address": "24, Rue de la Paix",
          "doneBefore": "tomorrow 13:00"
        },
        "dropoff": {
          "address": "48, Rue de Rivoli",
          "doneBefore": "tomorrow 13:30"
        }
      }
      """
    Then the response status code should be 201
    And the response should be in JSON
    And the JSON should match:
      """
      {
        "@context":"/api/contexts/Delivery",
        "@id":"@string@.startsWith('/api/deliveries')",
        "@type":"http://schema.org/ParcelDelivery",
        "id":@integer@,
        "pickup":{
          "id":@integer@,
          "address":{
            "@context":"/api/contexts/Address",
            "@id":"@string@.startsWith('/api/addresses')",
            "@type":"http://schema.org/Place",
            "geo":{
              "latitude":@double@,
              "longitude":@double@
            },
            "streetAddress":@string@,
            "telephone":null,
            "name":null
          },
          "doneBefore":"@string@.isDateTime()"
        },
        "dropoff":{
          "id":@integer@,
          "address":{
            "@context":"/api/contexts/Address",
            "@id":"@string@.startsWith('/api/addresses')",
            "@type":"http://schema.org/Place",
            "geo":{
              "latitude":@double@,
              "longitude":@double@
            },
            "streetAddress":@string@,
            "telephone":null,
            "name":null
          },
          "doneBefore":"@string@.isDateTime()"
        },
        "color":@string@
      }
      """

  Scenario: Create delivery with implicit pickup address & implicit time
    Given the fixtures file "stores.yml" is loaded
    And the user "bob" is loaded:
      | email      | bob@coopcycle.org |
      | password   | 123456            |
    And the store with name "Acme" belongs to user "bob"
    And the store with name "Acme" is authenticated as "bob"
    When I add "Content-Type" header equal to "application/ld+json"
    And I add "Accept" header equal to "application/ld+json"
    And the user "bob" sends a "POST" request to "/api/deliveries" with body:
      """
      {
        "dropoff": {
          "address": "48, Rue de Rivoli",
          "doneBefore": "2018-08-29 13:30:00"
        }
      }
      """
    Then the response status code should be 201
    And the response should be in JSON
    Then print last response
    And the JSON should match:
      """
      {
        "@context":"/api/contexts/Delivery",
        "@id":"@string@.startsWith('/api/deliveries')",
        "@type":"http://schema.org/ParcelDelivery",
        "id":@integer@,
        "pickup":{
          "id":@integer@,
          "address":{
            "@context":"/api/contexts/Address",
            "@id":"@string@.startsWith('/api/addresses')",
            "@type":"http://schema.org/Place",
            "geo":{
              "latitude":@double@,
              "longitude":@double@
            },
            "streetAddress":@string@,
            "telephone":null,
            "name":null
          },
          "doneBefore":"@string@.startsWith('2018-08-29')"
        },
        "dropoff":{
          "id":@integer@,
          "address":{
            "@context":"/api/contexts/Address",
            "@id":"@string@.startsWith('/api/addresses')",
            "@type":"http://schema.org/Place",
            "geo":{
              "latitude":@double@,
              "longitude":@double@
            },
            "streetAddress":@string@,
            "telephone":null,
            "name":null
          },
          "doneBefore":"@string@.startsWith('2018-08-29T13:30:00')"
        },
        "color":@string@
      }
      """
