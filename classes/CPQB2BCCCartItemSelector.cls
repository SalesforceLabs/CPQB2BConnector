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
public with sharing class CPQB2BCCCartItemSelector extends CPQB2BSelector {
    /**
     * CPQB2BCCCartSelector Class constructor
     */
    public CPQB2BCCCartItemSelector() {
        super(Schema.ccrz__E_CartItem__c.SObjectType);
    }

    /**
     * getDefaultFields Returns the default set of fields to query against CCCartItem
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'ccrz__Product__c',
            'ccrz__Quantity__c'
        };
    }

    /**
     * getCartItemsByCartId Retrieves CCCart Item records matching the provided cart id
     * @param  recordId Id of the CCCart to query for
     * @return          ccrz__E_CartItem__c record
     */
    public List<ccrz__E_CartItem__c> getCartItemsByCartId(Id cartId){
        List<String> queryFields = new List<String>(this.getDefaultFields());
        
        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_CartItem__c';
        query += ' WHERE ccrz__Cart__c =: cartId';
        query += ' WITH SECURITY_ENFORCED';

        return (List<ccrz__E_CartItem__c>)Database.query(query);
    }
}