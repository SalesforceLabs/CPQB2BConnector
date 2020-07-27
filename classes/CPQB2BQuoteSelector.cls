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
* @description Selector class for SBQQ__Quote__c
*/
public class CPQB2BQuoteSelector extends CPQB2BSelector {
    /**
    * @description Constructor that sets SObjectType
    */  
	public CPQB2BQuoteSelector() {
        super(Schema.SBQQ__Quote__c.SObjectType);
    }
    
    /**
     * getDefaultFields Returns the default set of fields to query against Product2
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'SBQQ__PricebookId__c',
            'SBQQ__Account__c',
            'SBQQ__Account__r.Name',
            'SBQQ__Account__r.ccrz__E_AccountGroup__c',
            'SBQQ__Account__r.ccrz__E_AccountGroup__r.Name',
            'Sync_Quote_To_B2B__c',
            'SBQQ__Primary__c',
            'SBQQ__Status__c',
            'SBQQ__ExpirationDate__c',
            'B2B_Source_Order__c'
        };
    }
    
     /** 
     * @description Returns a single SBQQ__Quote__c record by id 
     * @param Id recordId
     * @return  SBQQ__Quote__c
     */
    public SBQQ__Quote__c selectQuoteById(Id recordId) {
        Set<String> queryFields = new Set<String>(this.getDefaultFields());
        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('CurrencyIsoCode');
        }
        return (SBQQ__Quote__c) this.getRecordById(recordId,queryFields);
    }

     /** 
     * @description Returns a List of SBQQ__Quote__c record by id 
     * @param List<Id> recordIds
     * @return  List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectQuotesByIds(List<Id> recordIds){
        Set<String> queryFields = new Set<String>(this.getDefaultFields());
        Set<Id> recordIdSet = new Set<Id>(recordIds);
        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('CurrencyIsoCode');
        }
        return (List<SBQQ__Quote__c>) this.getRecordsByIds(recordIdSet,queryFields);
    }
}