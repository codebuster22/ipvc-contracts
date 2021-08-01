// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./VaccineToken.sol";

contract IPVC {

    // state
    mapping( uint8 => bytes32 ) dose_types;
    mapping( uint16 => string ) countries;

    // what is the entity
    // - CountryAuthority. This is the person/organisation/entity responsible for vaccination drives in a country.
    // how it can be accessed
    // - it can be accessed using address only (we need them to have private key to sign transactions)
    // how can it interact
    // - approve/revoke vaccinators
    // what should we know about this entity
    // - who is this linked to in real life (The organization that handle the vaccination drives)
    // - who controls this country authority (admin)
    // - are they allowed to practice (allowed by IPVC only)
    // - which Country
    // - the official public portal used by this country to verify certificate
    // - who all are apporved to act upon as Country Authority (Crew Members)
    struct CountryAuthority{
        uint16    country_id;
        bytes32[] vaccinators;
        address   admin;
        bytes     verifing_uri;
        uint8     ipvc_approved;
    }
    // ipvc_country_authority_id => CountryAuthority
    mapping(bytes32 => CountryAuthority) country_authorities;
    // ipvc_country_authority_id => address => bool
    mapping(bytes32 => mapping(address => uint8)) country_authority_crew;

    // what is the entity
    // - beneficiary. This is the person who gets vaccinated.
    // how it can be accessed
    // - it can be accessed using address, govId
    // how can it interact
    // - it can only view data
    // - they can ask the vaccinator to update details
    // what should we know about this entity
    // - who is this linked to in real life (country's citizen)
    struct Beneficiary{
        bytes     country_beneficiary_id;
        bytes32[] vaccineTokens;
        address   beneficiary;
    }
    // ipvc_beneficiary_id => Beneficiary
    mapping( bytes32 => Beneficiary ) beneficiaries;
    // hashed govId => beneficiaryId
    // // keccak256(COUNTRYCODE+IDTYPE+IDNUMBER) - govID
    mapping( bytes32 => bytes32 ) linked_ids;

    // what is the entity
    // - Vaccinator. This is an entity who vaccinates beneficiaries.
    // how it can be accessed
    // - it can be accessed using address only (we need them to have private key to sign transactions)
    // how can it interact
    // - it can create/update/view data. They cannot delete the data
    // - they act on behalf of the beneficiary
    // what should we know about this entity
    // - who is this linked to in real life (the place where vaccine details is validated)
    // - who controls this vaccinator (admin)
    // - are they allowed to practice
    // - which country do they belong to
    // - the official registration ID (an ID generated in country) for this vaccinator
    // - vaccine tokens created by this vaccinator
    struct Vaccinator{
        uint16    country_id;
        bytes     vaccinator_registration_id;
        address   admin;
        uint8     rights_to_practice;
        bytes32[] vaccinator_certificates;
    }
    // ipvc_vaccinator_id = hash(COUNTRY_CODE+REGISTRATION_ID)
    // ipvc_vaccinator_id => Vaccinator
    mapping(bytes32 => Vaccinator) public vaccinators;
    // address => ipvc_vaccinator_id
    mapping(address => bytes32) public vaccinator_crew;

}