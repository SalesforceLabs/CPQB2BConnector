/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


@isTest
public class CPQB2BSelectorTest {
	private static Boolean isNotSetup = true; // Used to determine if the setup method has been called by other setups

	@TestSetup
	public static void setup() {
		if (isNotSetup) {

			List<Account> acctsToSetup = new List<Account>();
			for (Integer i=0; i<200; i++) {
				acctsToSetup.add(new Account(Name = 'Test Customer Account: ' + i));
			}
			insert acctsToSetup;

			isNotSetup = false;
		}
	}
	
	@isTest
	public static void constructors() {
		new AccountSelectorTest();
	}
	
	@isTest
	public static void getSObjectType() {
		CPQB2BSelector s = new AccountSelectorTest();
		System.assertEquals(Schema.Account.SObjectType, s.getSObjectType());
	}
	
	@isTest
	public static void getSObjectName() {
		CPQB2BSelector s = new AccountSelectorTest();
		System.assertEquals('Account', s.getSObjectName());
	}

	@isTest
	public static void getDefaultQuery() {
		CPQB2BSelector s = new AccountSelectorTest();
		System.assert(s.getDefaultQuery().startsWith('SELECT '));
		System.assert(s.getDefaultQuery().endsWith(' FROM Account '));
	}
	
	@isTest
	public static void getAllRecords() {
		CPQB2BSelector s = new AccountSelectorTest();
		
		List<SObject> recs = s.getAllRecords();
		
		System.assertEquals(200, recs.size());
	}
	
	@isTest
	public static void getRecordById() {
		CPQB2BSelector s = new AccountSelectorTest();
		
		Account a = [SELECT Id FROM Account LIMIT 1];
		
		SObject rec = s.getRecordById(a.Id);
		
		System.assertNotEquals(null, rec);
		System.assertEquals(a.Id, rec.Id);
	}
	
	@isTest
	public static void getRecordsByIds() {
		CPQB2BSelector s = new AccountSelectorTest();
		
		Set<Id> acctIds = new Map<Id,Account>([SELECT Id FROM Account]).keySet();
		
		List<SObject> recs = s.getRecordsByIds(acctIds);
		
		System.assertEquals(200, recs.size());
	}
	
	/**
	 * A concrete instance of a selector that uses a standard object
	 * so that we can have out-of-the
	 */
	public class AccountSelectorTest extends CPQB2BSelector {
		public AccountSelectorTest() {
			super(Schema.Account.SObjectType);
		}

		public override Set<String> getDefaultFields() {
			return new Set<String>{
				'Id',
				'Name',
				'Description'
			};
		}
	}
}