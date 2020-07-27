/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Ashlee Zeigler
* @date 3/5/2020
*
* @see CPQB2BSelector
* @description Selector class for CC Order Item
*/
public with sharing class CPQB2BCCOrderItemSelector extends CPQB2BSelector {
    /*******************************************************************************************************
  * @description Constructor that sets SObjectType
  */  
  public CPQB2BCCOrderItemSelector() {
      super(Schema.ccrz__E_OrderItem__c.SObjectType);
  }

  /*******************************************************************************************************
  * @description Returns a Set that has all of the default fields. 
  * @return Set of Strings that contain the default fields for this objec
  */
  public override Set<String> getDefaultFields() {
      return new Set<String>{
          'Id',
          'ccrz__ItemStatus__c',
          'ccrz__Order__c',
          'ccrz__OrderLineType__c',
          'ccrz__OriginalItemPrice__c',
          'ccrz__OriginalQuantity__c',
          'ccrz__Price__c',
          'ccrz__Product__c',
          'ccrz__ProductType__c',
          'ccrz__Quantity__c',
          'ccrz__UnitOfMeasure__c',
          'Source_Order_Item__c',
          'ccrz__SubAmount__c'
      };
  }

  /**
   * getMappedFields Returns the mapped fields from custom metadata
   * @return   Set<String> of field names
   */
  public Set<String> getMappedFields() {
      Set<String> customFieldsToQuery = new Set<String>();

      List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getCustomOrderItemToCCOrderItemFieldMappings();
      if(fieldMappings != null){
          for(CPQB2BBaseFieldMapping fieldMap : fieldMappings) {
              if (fieldMap.destField != null) {
                customFieldsToQuery.add(fieldMap.destField);
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
   * @description Returns a list of ccrz__E_OrderItem__c by ids 
   * @param Id orderIds
   * @return  ccrz__E_Order__c
   */
  public List<ccrz__E_OrderItem__c> getByOrderIds(List<Id> orderIds) {
      List<String> queryFields = new List<String>(getFields());

      String query = 'SELECT ' + String.join(queryFields, ',');
      query += ' FROM ccrz__E_OrderItem__c';
      query += ' WHERE ccrz__Order__c IN :orderIds';
      query += ' AND IsDeleted = false';
      query += ' WITH SECURITY_ENFORCED';

      return (List<ccrz__E_OrderItem__c>)Database.query(query);
  }
}