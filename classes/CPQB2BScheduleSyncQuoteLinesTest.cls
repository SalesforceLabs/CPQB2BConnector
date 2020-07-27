/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BScheduleSyncQuoteLinesTest {
    
    @isTest
    public static void testScheduleBatch() {
        Test.startTest();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('ScheduleSyncQuoteLines', CRON_EXP, new CPQB2BScheduleSyncQuoteLines());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            System.assertEquals(0, ct.TimesTriggered); 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));         
        Test.stopTest();
    }
}