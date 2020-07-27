/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 2-20-2020
*
* @see CPQB2BSelector
* @description Selector class for CCAccountGroupPriceList
*/
public with sharing class CPQB2BCCAccountGrpPriceListSelector extends CPQB2BSelector {
 /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */  
    public CPQB2BCCAccountGrpPriceListSelector() {
        super(Schema.ccrz__E_AccountGroupPriceList__c.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields. 
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'ccrz__AccountGroup__c',
            'ccrz__Pricelist__c',
            'ccrz__Pricelist__r.Source_Price_Book__c',
            'ccrz__Pricelist__r.ccrz__CurrencyISOCode__c'
        };
    }

    /*******************************************************************************************************
     * @description Returns a List of CC Account Group Price List records by AccountGroup Id 
     * @param Set<Id> ids
     * @return  List<ccrz__E_AccountGroupPriceList__c>
     */
    public List<ccrz__E_AccountGroupPriceList__c> getCCAccountGroupPriceListsByAccountGroupIds(List<Id> accountGroupIds) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_AccountGroupPriceList__c';
        query += ' WHERE ccrz__AccountGroup__c IN :accountGroupIds';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return (List<ccrz__E_AccountGroupPriceList__c>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Returns lowest sequenced CC Account Group Price List record by AccountGroup Id 
     * @param Id accountGrpId
     * @return  ccrz__E_AccountGroupPriceList__c
     */
    public ccrz__E_AccountGroupPriceList__c getLowestSequenceCCAccountGroupPriceList(Id accountGrpId) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_AccountGroupPriceList__c';
        query += ' WHERE ccrz__AccountGroup__c = :accountGrpId';
        query += ' AND IsDeleted = false';
        // WITH SECURITY BELOW

        //Check if org is using multi-currency, if true then we grab the correct
        //currency iso code from the user record (User.ccrz__CC_CurrencyCode__c)
        //and filter for pricelists associated to that currency only
        if (UserInfo.isMultiCurrencyOrganization()) {
            CPQB2BUserSelector userSelector = new CPQB2BUserSelector();
            User u = (User) userSelector.getRecordById(UserInfo.getUserId());
            String currencyCode = u.ccrz__CC_CurrencyCode__c;
            
            //If currency field is not populated for user then
            //assign default org currency.
            if(String.isBlank(currencyCode)){
                currencyCode = UserInfo.getDefaultCurrency();
            }
            
            query += ' AND ccrz__Pricelist__r.ccrz__CurrencyISOCode__c = :currencyCode';
        }

        query += ' WITH SECURITY_ENFORCED';
        query += ' ORDER BY ccrz__Sequence__c ASC LIMIT 1';

        List<ccrz__E_AccountGroupPriceList__c> acctGrpPL = new List<ccrz__E_AccountGroupPriceList__c>();
        acctGrpPL = (List<ccrz__E_AccountGroupPriceList__c>)Database.query(query);

        if(acctGrpPL.isEmpty()){
            return null;
        }

        return acctGrpPL[0];
    }
}