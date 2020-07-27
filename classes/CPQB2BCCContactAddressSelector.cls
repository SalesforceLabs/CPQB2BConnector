/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 3-19-2020
*
* @see CPQB2BSelector
* @description Selector class for CPQB2BCCContactAddressSelector 
*/
public with sharing class CPQB2BCCContactAddressSelector extends CPQB2BSelector {
      /**
     * CPQB2BCCContactAddressSelector Class constructor
     */
    public CPQB2BCCContactAddressSelector() {
        super(Schema.ccrz__E_ContactAddr__c.SObjectType);
    }

    /**
     * getDefaultFields Returns the default set of fields to query
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'ccrz__AddressFirstline__c', 
            'ccrz__City__c',
            'ccrz__Country__c',           
            'ccrz__State__c',
            'ccrz__StateISOCode__c',
            'ccrz__PostalCode__c'
        };
    }

    /**
     * Selects the record by exact match
     * @param  List<Address> address
     * @return          List<ccrz__E_ContactAddr__c> record
     */
    public List<ccrz__E_ContactAddr__c> selectByFullAddress(List<Address> addresses){
        List<String> queryFields = new List<String>(this.getDefaultFields());

        List<String> streetList = new List<String>();
        List<String> cityList = new List<String>();
        List<String> countryList = new List<String>();
        List<String> stateList = new List<String>();
        List<String> postalCodeList = new List<String>();

        for (Address address : addresses) {
            streetList.add(address.Street);
            cityList.add(address.City);
            countryList.add(address.Country);
            stateList.add(address.State);
            postalCodeList.add(address.PostalCode);
        }

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_ContactAddr__c';
        query += ' WHERE ccrz__AddressFirstline__c IN :streetList';
        query += ' AND ccrz__City__c IN :  cityList';
        query += ' AND ccrz__Country__c IN : countryList';
        query += ' AND ccrz__StateISOCode__c IN : stateList';
        query += ' AND ccrz__PostalCode__c IN : postalCodeList';
        query += ' WITH SECURITY_ENFORCED';
        
        List<ccrz__E_ContactAddr__c> results = new List<ccrz__E_ContactAddr__c>();
        results = Database.query(query);
        if (results == null) {
            return new List<ccrz__E_ContactAddr__c>();
        }
        return results;
    }
}