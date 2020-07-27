/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 2-17-2020
* @see CPQB2BSelector
* @description Selector class for CCPriceList
*/
public with sharing class CPQB2BCCPriceListSelector extends CPQB2BSelector {
    /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */  
    public CPQB2BCCPriceListSelector() {
        super(Schema.ccrz__E_PriceList__c.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields. 
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'ccrz__PricelistId__c',
            'ccrz__CurrencyISOCode__c',
            'ccrz__Enabled__c',
            'ccrz__EndDate__c',
            'ccrz__Seller__c',
            'ccrz__StartDate__c',
            'ccrz__Storefront__c',
            'Source_Price_Book__c'
        };
    }

    /*******************************************************************************************************
     * @description Returns CCPriceLists by ids
     * @param List<Id> CCPriceList ids
     * @return  List<ccrz__E_PriceList__c>
     */
    public List<ccrz__E_PriceList__c> getCCPricesListsByIds(List<Id> recordIds) {
        Set<String> queryFields = new Set<String>(this.getDefaultFields());
        Set<Id> recordIdSet = new Set<Id>(recordIds);
        return (List<ccrz__E_PriceList__c>) this.getRecordsByIds(recordIdSet,queryFields);
    }

    /*******************************************************************************************************
     * @description Returns a single CCPriceList record by pricebook id 
     * @param Id priceBookId
     * @return  ccrz__E_PriceList__c
     */
    public ccrz__E_PriceList__c getCCPriceListByPriceBookId(Id priceBookId) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_PriceList__c';
        query += ' WHERE Source_Price_Book__c = :priceBookId';
        query += ' AND IsDeleted = false';
        // System.debug(Security.stripInaccessible(AccessType.READABLE, Database.query(query)).getRemovedFields());
        query += ' WITH SECURITY_ENFORCED';

        List<ccrz__E_PriceList__c> results = (List<ccrz__E_PriceList__c>)Database.query(query);
        if (results.size() == 1) {
            return results[0];
        }
        return null;
    }

    /*******************************************************************************************************
     * @description Returns a single CCPriceList record by pricebook id 
     * @param List<Id> priceBookIds
     * @return  List<ccrz__E_PriceList__c>
     */
    public List<ccrz__E_PriceList__c> getCCPriceListsByPriceBookIds(List<Id> priceBookIds) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_PriceList__c';
        query += ' WHERE Source_Price_Book__c IN :priceBookIds';
        query += ' AND IsDeleted = false';
        // System.debug(Security.stripInaccessible(AccessType.READABLE, Database.query(query)).getRemovedFields());
        query += ' WITH SECURITY_ENFORCED';

        return (List<ccrz__E_PriceList__c>)Database.query(query);
    }
}