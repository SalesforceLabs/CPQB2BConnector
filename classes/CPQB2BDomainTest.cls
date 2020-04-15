/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @description CPQB2BDomainTest class that handles testing and code coverage for the CPQB2BDomain class
*/

@isTest
public class CPQB2BDomainTest {
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
	public static void getSObjectType() {
		AccountDomainTest adt = new AccountDomainTest([SELECT Id, Name FROM Account]);
		
		System.assertEquals(Schema.Account.SObjectType, adt.getSObjectType());
	}
	
	@isTest
	public static void getSObjectName() {
		AccountDomainTest adt = new AccountDomainTest([SELECT Id, Name FROM Account]);
		
		System.assertEquals('Account', adt.getSObjectName());
	}

	/**
	 * A concrete instance of a selector that uses a standard object
	 * so that we can have out-of-the
	 */
	public class AccountDomainTest extends CPQB2BDomain {
		public AccountDomainTest(List<Account> records) {
			super(records);
		}
		
	}
}