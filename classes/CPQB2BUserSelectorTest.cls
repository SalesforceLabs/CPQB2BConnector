/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BUserSelectorTest {
    @isTest
    public static void testGetByContactIds() {
        Map<String, Object> testData = cc_TestDataFactory.setupAccountContactUser(false);
        Id userId = ((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;
        Id accountId = ((Account) testData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;
        Id contactId = ((Contact) testData.get(cc_TestDataFactory.TEST_CONTACT)).Id;
      
        System.RunAs((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)) {
            Test.startTest();
            List<User> results = new CPQB2BUserSelector().getByContactIds(new List<Id>{contactId});
            System.assertEquals(1, results.size());
            Test.stopTest();
        }
    }
}