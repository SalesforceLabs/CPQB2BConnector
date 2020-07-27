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
* @description Selector class for SBQQ__QuoteLine__c
*/
public with sharing class CPQB2BQuoteLineSelector extends CPQB2BSelector {
    /**
    * @description Constructor that sets SObjectType
    */  
	public CPQB2BQuoteLineSelector() {
        super(Schema.SBQQ__QuoteLine__c.SObjectType);
    }
    
    /**
     * getDefaultFields Returns the default set of fields to query against Product2
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'SBQQ__Quote__c',
            'SBQQ__NetPrice__c',
            'SBQQ__Product__c',
            'SBQQ__Quote__r.SBQQ__Account__r.Name',
            'SBQQ__Quote__r.SBQQ__Account__r.ccrz__E_AccountGroup__c',
            'SBQQ__Quote__r.Sync_Quote_To_B2B__c',
            'SBQQ__Quote__r.SBQQ__Primary__c',
            'SBQQ__Quote__r.SBQQ__Status__c',
            'SBQQ__Quote__r.SBQQ__ExpirationDate__c'
        };
    }

    /**
     * getMappedFields Returns the mapped fields from custom metadata
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getCustomQuoteLineFieldMappings();
        if(fieldMappings != null){
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                if (fieldMap.sourceField != null) {  
                    customFieldsToQuery.add(fieldMap.sourceField); 
                }
            }
        }
        return customFieldsToQuery;
    }

    /**
   * getMappedFields Returns the combined list of default fields and mapped fields to ensure no duplicate columns are queried
   * @return   Set<String> of field names
   */
    public Set<String> getFields() {
        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(getDefaultFields());
        fieldsToQuery.addAll(getMappedFields());
        return fieldsToQuery;
    }
    
     /** 
     * @description Returns a single SBQQ__QuoteLine__c record by id 
     * @param Id recordId
     * @return  SBQQ__QuoteLine__c
     */
    public SBQQ__QuoteLine__c selectQuoteLineById(Id recordId){
        Set<String> queryFields = new Set<String>(this.getFields());

        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('SBQQ__Quote__r.CurrencyIsoCode');
        }
        return (SBQQ__QuoteLine__c) this.getRecordById(recordId,queryFields);
    }

     /** 
     * @description Returns a List of SBQQ__QuoteLine__c record by id 
     * @param List<Id> recordIds
     * @return  List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLinesByIds(List<Id> recordIds){
        Set<String> queryFields = new Set<String>(this.getFields());

        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('SBQQ__Quote__r.CurrencyIsoCode');
        }
        Set<Id> recordIdSet = new Set<Id>(recordIds);
        return (List<SBQQ__QuoteLine__c>) this.getRecordsByIds(recordIdSet,queryFields);
    }

     /** 
     * @description Returns a List of SBQQ__QuoteLine__c record by id 
     * @param List<Id> recordIds
     * @return  List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLinesByQuoteIds(List<Id> quoteIds){
        List<String> queryFields = new List<String>(this.getFields());

        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('SBQQ__Quote__r.CurrencyIsoCode');
        }
        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Quote__c IN :quoteIds';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return (List<SBQQ__QuoteLine__c>) Database.query(query);
    }

    /** 
     * @description Get the SBQQ__QuoteLine__c QueryLocator for records should be synced to B2B
     *   
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator selectQuoteLinesToSyncToB2B() {
        List<String> queryFields = new List<String>(this.getFields());

        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('SBQQ__Quote__r.CurrencyIsoCode');
        }

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Quote__r.Sync_Quote_To_B2B__c = true';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
}