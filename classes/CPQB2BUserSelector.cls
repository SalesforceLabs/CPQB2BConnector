/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


public with sharing class CPQB2BUserSelector extends CPQB2BSelector {
    /*******************************************************************************************************
       * @description Constructor that sets SObjectType
       */  
       public CPQB2BUserSelector() {
           super(Schema.User.SObjectType);
       }
   
       /*******************************************************************************************************
       * @description Returns a Set that has all of the default fields. 
       * @return Set of Strings that contain the default fields for this object
       */
       public override Set<String> getDefaultFields() {
           return new Set<String>{
               'Id',
               'ContactId',
               'Name',
               'ccrz__CC_CurrencyCode__c'
           };
       }
   
       /*******************************************************************************************************
        * @description Returns a List of Users By ContactIds
        * @param Set<Id> ids
        * @return  List<User>
        */
       public List<User> getByContactIds(List<Id> ids) {
           List<String> queryFields = new List<String>(this.getDefaultFields());
   
           String query = 'SELECT ' + String.join(queryFields, ',');
           query += ' FROM User';
           query += ' WHERE ContactId IN :ids';
           query += ' AND IsActive = true';
           query += ' WITH SECURITY_ENFORCED';
   
           return (List<User>)Database.query(query);
       }
   }