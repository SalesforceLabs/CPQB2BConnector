/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @description Product2 Selector class that handles ability to query Product2 object by different contexts
*/

public with sharing class CPQB2BProduct2Selector extends CPQB2BSelector{
    
	public CPQB2BProduct2Selector() {
        super(Schema.Product2.SObjectType);
    }
    
    /**
     * getDefaultFields Returns the default set of fields to query against Product2
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Description',
            'Name',
            'ProductCode',
            'Sync_Product_To_B2B__c',
            'IsActive',
            'B2B_Storefront__c'
        };
    }

    /**
     * getDefaultFields Returns the default set of fields to query against Product2
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> productFieldMappings = CPQB2BFieldMapping.getCustomProductFieldMappings();
        if(productFieldMappings!=null){
            for(CPQB2BBaseFieldMapping fieldMap : productFieldMappings){
                customFieldsToQuery.add(fieldMap.sourceField);
            }
        }
        return customFieldsToQuery;
    }

    public Set<String> getFields() {
        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(getDefaultFields());
        fieldsToQuery.addAll(getMappedFields());
        return fieldsToQuery;
   }

    public List<Product2> getProductByName(String name){
        List<String> queryFields = new List<String>(this.getFields());
        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Product2';
        query += ' WHERE Name =: name';
        query += ' WITH SECURITY_ENFORCED';
        query += ' LIMIT 100';

        return (List<Product2>)Database.query(query);
    }
    
    public Product2 selectById(Id recordId){
        Set<String> queryFields = new Set<String>(this.getFields());
        queryFields.addAll(this.getMappedFields());
        return (Product2) this.getRecordById(recordId,queryFields);
    }

    public List<Product2> selectByIds(List<Id> recordIds){
        Set<String> queryFields = new Set<String>(this.getFields());
        Set<Id> recordIdSet = new Set<Id>(recordIds);
        return (List<Product2>) this.getRecordsByIds(recordIdSet,queryFields);
    }

    
    /**
     * getProductRecordsToSync returns query for batch Product syncing
     * @return                 Database.getQueryLocator
     */
    public Database.QueryLocator getProductRecordsToSync() {
        List<String> queryFields = new List<String>(this.getFields());
        DateTime lastModifiedDate = Datetime.now().addDays(-1);

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Product2';
        query += ' WHERE SystemModStamp > :lastModifiedDate';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
}