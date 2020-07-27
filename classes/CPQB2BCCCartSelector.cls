/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Amil Abdallah
* @date 02/26/2020
*
* @description CCCart Selector class that handles ability to query CCCart object by different contexts
*/
public with sharing class CPQB2BCCCartSelector extends CPQB2BSelector {
    /**
     * CPQB2BCCCartSelector Class constructor
     */
    public CPQB2BCCCartSelector() {
        super(Schema.ccrz__E_Cart__c.SObjectType);
    }

    /**
     * getDefaultFields Returns the default set of fields to query against CCCart
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'ccrz__Account__c',
            'ccrz__Storefront__c'
        };
    }

    /**
     * selectById Retrieves CCCart record matching the provided Id
     * @param  recordId Id of the CCCart to query for
     * @return          ccrz__E_Cart__c record
     */
    public ccrz__E_Cart__c selectByEncryptionId(String encryptedId){
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_Cart__c';
        query += ' WHERE ccrz__EncryptedId__c = : encryptedId';
        query += ' WITH SECURITY_ENFORCED';

        List<ccrz__E_Cart__c> cartList = new List<ccrz__E_Cart__c>();
        cartList = Database.query(query);

        if(cartList.isEmpty()){
            return null;
        }

        return cartList[0];
    }
}