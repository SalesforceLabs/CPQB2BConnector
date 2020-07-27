/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Amil Abdallah
* @date 3-08-2020
*
*
* @description Service class for CC Cart Object
*/
public with sharing class CPQB2BCCCartService {
    
    /*******************************************************************************************************
    * @description Updates a cart's status to the custom defined value for the CPQB2B process.  This method
    * is called after a quote has successfully been generated for the associated carts.
    * @param List<ccrz__E_Cart__c> carts
    */
    public static void setCartToQuoteRequested(List<ccrz__E_Cart__c> carts)
    {
        String cartStatus = CPQB2BMappingSelector.getCustomCartStatus();

        for(ccrz__E_Cart__c cart : carts){
            cart.ccrz__ActiveCart__c = false;
            cart.ccrz__CartStatus__c = cartStatus;
        }
        if(Schema.SObjectType.ccrz__E_Cart__c.fields.ccrz__ActiveCart__c.isUpdateable() && 
            Schema.SObjectType.ccrz__E_Cart__c.fields.ccrz__CartStatus__c.isUpdateable()){
                update carts;
            } else {
                throw new SecurityException('Object or Field Access on ccrz__E_Cart__c not available to current user');
            }
    }
}