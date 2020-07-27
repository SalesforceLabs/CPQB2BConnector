/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 2-26-2020
*
* @see CPQB2BSelector
* @description Selector class for Order
*/
public with sharing class CPQB2BOrderSelector extends CPQB2BSelector {
    /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */
    public CPQB2BOrderSelector() {
        super(Schema.Order.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields.
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'AccountId',
            'EffectiveDate',
            'Name',
            'Sync_to_B2B__c',
            'CustomerAuthorizedById',
            'ShipToContactId',
            'B2B_Source_Order__c',
            'SBQQ__Quote__c',
            'SBQQ__Quote__r.B2B_Source__c',
            'ShippingAddress',
            'BillingAddress'
        };
    }

    /**
     * getMappedFields Returns the mapped fields from custom metadata
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getCustomOrderToCCOrderMappings();
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

    /*******************************************************************************************************
     * @description Returns a list of orders by ids
     * @param Id orderIds
     * @return  Order
     */
    public List<Order> getByIds(List<Id> orderIds) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Order';
        query += ' WHERE Id IN :orderIds';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return (List<Order>)Database.query(query);
    }

     /*******************************************************************************************************
     * @description Returns a list of orders by quote ids
     * @param Id quoteIds
     * @return  List<Order>
     */
    public List<Order> getByQuoteIds(List<Id> quoteIds) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Order';
        query += ' WHERE SBQQ__Quote__c IN :quoteIds';
        query += ' AND IsDeleted = false';

        query += ' WITH SECURITY_ENFORCED';

        return (List<Order>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Returns a list of orders by source order ids
     * @param Id quoteIds
     * @return  List<Order>
     */
    public List<Order> getBySourceOrderIds(List<Id> sourceOrderIds) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Order';
        query += ' WHERE B2B_Source_Order__c IN :sourceOrderIds';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return (List<Order>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Get the Order QueryLocator for records that have not been synced
     *
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator getOrdersToSync() {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Order';
        query += ' WHERE Sync_to_B2B__c = true ';
        query += ' AND IsDeleted = false';
        query += ' WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
}