/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BLoggingServiceTest {
    
    @isTest
    public static void testExceptionLoggingService() {
        Test.startTest();
        CPQB2BLogger logger = new CPQB2BLogger();

        List<ccrz__E_Product__c> ccProdList = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
        ccProduct1.Name = 'CPQB2B - TestProduct1';
        ccProduct1.ccrz__SKU__c = '1234';
        ccProdList.add(ccProduct1);

        logger.log(CPQB2BProcessType.SKU.name(),'Batch',new DMLException(),ccProdList);          

        logger.write();

        Test.stopTest();
        
        List<CPQB2BLog__c> logList = [Select Id, Process_Type__c,Record_Id__c,Source_Record_Id__c,Error_Message__c,Stack_Trace__c,Triggering_Event__c, CreatedDate FROM CPQB2BLog__c];
        System.assertEquals(1,logList.size(),'The returned list size of ' + logList.size() + ' does not match the expected value of 1.');

    }
}