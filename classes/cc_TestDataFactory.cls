/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class cc_TestDataFactory {
    
    public static final String TEST_STOREFRONT = 'DefaultStore';
   
    // Parent Billing Address    
    public static final String PARENT_BILL_STREET = 'Parent Billing Address';
    public static final String PARENT_BILL_CITY = 'New York';
    public static final String PARENT_BILL_STATE = 'NY';
    public static final String PARENT_BILL_COUNTRY = 'US';
    public static final String PARENT_BILL_POSTAL_CODE = '67890';
    // Parent Shipping Address    
    public static final String PARENT_SHIP_STREET = 'Parent Shipping Address';
    public static final String PARENT_SHIP_CITY = 'New York';
    public static final String PARENT_SHIP_STATE = 'NY';
    public static final String PARENT_SHIP_COUNTRY = 'US';
    public static final String PARENT_SHIP_POSTAL_CODE = '67890';
    // Child billing address    
    public static final String CHILD_BILL_STREET = 'Child Billing Address';
    public static final String CHILD_BILL_CITY = 'Chicago';
    public static final String CHILD_BILL_STATE = 'IL';
    public static final String CHILD_BILL_COUNTRY = 'US';
    public static final String CHILD_BILL_POSTAL_CODE = '12345';
    // Child shipping address    
    public static final String CHILD_SHIP_STREET = 'Child Shipping Address';
    public static final String CHILD_SHIP_CITY = 'Chicago';
    public static final String CHILD_SHIP_STATE = 'IL';
    public static final String CHILD_SHIP_COUNTRY = 'US';
    public static final String CHILD_SHIP_POSTAL_CODE = '12345';
    // CC Contact Address    
    public static final String ADDRESS_FIRSTLINE = 'addressFirstline';
    public static final String CITY = 'city';
    public static final String STATE = 'state';
    public static final String COUNTRY = 'country';
    public static final String POSTAL_CODE = 'postalCode';
    public static final String DAYTIME_PHONE = 'daytimePhone';
    // Random test address    
    public static final String TEST_STREET = 'Testing Address';
    public static final String TEST_CITY = 'Chicago';
    public static final String TEST_STATE = 'PA';
    public static final String TEST_COUNTRY = 'US';
    public static final String TEST_POSTAL_CODE = '12001';
    public static final String TEST_ACC_FIRSTNAME = 'Test';
    public static final String TEST_ACC_LASTNAME = 'Account';
    public static final String PRODUCT_TYPE_PRODUCT = 'Product';
    public static final String PRODUCT_STATUS_RELEASED = 'Released';
    public static final String CART_STATUS_OPEN = 'Open';
    public static final String CART_TYPE = 'Cart';
    public static final String TEST_CURRENCY_CODE = 'USD';
    public static final String TEST_ENCRYPTED_ID_CART = 'encid-';
    public static final String TEST_PARENT_ACC_USER = 'TestParentUser';
    public static final String TEST_CHILD_ACC_USER = 'TestUser';
    public static final String TEST_PARENT_ACCOUNT = 'TestParentAccount';
    public static final String TEST_CHILD_ACCOUNT = 'TestChildAccount';
    public static final String TEST_PRODUCTS = 'TestProducts';
    public static final String TEST_CONTACT = 'TestContact';
    public static final String TEST_SKU = 'TestSKU';
    public static final Integer TEST_PRODUCT_PRICE = 50;
    private static final Decimal TEST_ACCOUNT_CREDIT_LIMIT = 100;

    /**     * @description Setups a test storefront.     */    
    public static void initCCSettings() {        
        ccrz.cc_util_Reflection.createStorefrontSetting(TEST_STOREFRONT);
        Map<String, Map<String, Object>> ccSettings = new Map<String, Map<String, Object>>{
            /*
                ccrz.ccApiTestData.SERVICE_SETTINGS => new Map<String, Object>{                        
                        TEST_STOREFRONT => new Map<String, Object>{                                
                            'ccServiceAccount' => 'c.cpqb2b_ccServiceAccount',                                
                            'ccServiceProduct' => 'c.cpqb2b_ccServiceAccount'                        
                        }                
                    },                
                ccrz.ccApiTestData.LOGIC_SETTINGS => new Map<String, Object>{                        
                TEST_STOREFRONT => new Map<String, Object>{
                    'ccLogicCartCreate' => 'c.<My Logic class override>',                                
                    'ccLogicCartValidate' => 'c.<My Logic class override>'}                
                },                
                ccrz.ccApiTestData.HOOK_SETTINGS => new Map<String, Object>{                        
                    TEST_STOREFRONT => new Map<String, Object>{                                
                        ccrz.cc_hk_Payment.HK_ID => 'c.<My Hook class override>',                                
                        ccrz.cc_hk_Order.HK_ID => 'c.<My Hook class override>',                                
                        ccrz.cc_hk_UserInterface.HK_ID => 'c.<My Hook class override>'                        
                    }                
                }   
            */                
     
    };
    ccrz.ccApiTestData.setupData(ccSettings);
}    

    /**     * @description Returns a test Account.     */    
    public static Account createInsertTestAccount(ccrz__E_AccountGroup__c accountGroup, Boolean isParent, Account parentAccount) {        
        Account testAcc = new Account();
        if (isParent) {            
            testAcc.Name = 'Parent Account';
            testAcc.BillingStreet = PARENT_BILL_STREET;
            testAcc.BillingCity = PARENT_BILL_CITY;
            testAcc.BillingState = PARENT_BILL_STATE;
            testAcc.BillingCountry = PARENT_BILL_COUNTRY;
            testAcc.BillingPostalCode = PARENT_BILL_POSTAL_CODE;
            testAcc.ShippingStreet = PARENT_SHIP_STREET;
            testAcc.ShippingCity = PARENT_SHIP_CITY;
            testAcc.ShippingState = PARENT_SHIP_STATE;
            testAcc.ShippingCountry = PARENT_SHIP_COUNTRY;
            testAcc.ShippingPostalCode = PARENT_SHIP_POSTAL_CODE;
        } else {            
            testAcc.Name = 'Child Account';
            /*  
            Commenting out these fields as they do not exist in our Orgs
            The test methods in CCLogicCartValidateTest seem depenedent on
            the use of these fields 
            

            testAcc.License_Expiration_Date__c = Date.today().addDays(5);
            testAcc.Credit_Limit__c = TEST_ACCOUNT_CREDIT_LIMIT;
            testAcc.Current_AR__c = 0;
            testAcc.Accounting_Status__c = 'Good';
            */
            testAcc.BillingStreet = CHILD_BILL_STREET;
            testAcc.BillingCity = CHILD_BILL_CITY;
            testAcc.BillingState = CHILD_BILL_STATE;
            testAcc.BillingCountry = CHILD_BILL_COUNTRY;
            testAcc.BillingPostalCode = CHILD_BILL_POSTAL_CODE;
            testAcc.ShippingStreet = CHILD_SHIP_STREET;
            testAcc.ShippingCity = CHILD_SHIP_CITY;
            testAcc.ShippingState = CHILD_SHIP_STATE;
            testAcc.ShippingCountry = CHILD_SHIP_COUNTRY;
            testAcc.ShippingPostalCode = CHILD_SHIP_POSTAL_CODE;
            if (parentAccount != null) {                
                testAcc.ParentId = parentAccount.Id;
            }        
        }        
        testAcc.ccrz__E_AccountGroup__c = accountGroup.Id;
        insert testAcc;
        return testAcc;
    }    
    
    /**     * @description Creates a test account group.     */    
    public static ccrz__E_AccountGroup__c createInsertTestAccountGroup() {        
        ccrz__E_AccountGroup__c accGroup = new ccrz__E_AccountGroup__c(                
            Name = 'Default Account Group',                
            ccrz__PriceListSelectionMethod__c = 'Best Price');
        insert accGroup;
        return accGroup;
    }    
    /**     * @description Creates and returns a test price list.     */    
    public static ccrz__E_PriceList__c createInsertTestPricelist() {        
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c(                
            Name = 'Test Price List',                
            ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE,                
            ccrz__Enabled__c = true,               
            ccrz__Storefront__c = TEST_STOREFRONT,                
            ccrz__StartDate__c = System.today().addYears(-1));
        insert priceList;
        return priceList;
    }    
    /**     * @description Associates the pricelist to an account group.     */    
    public static ccrz__E_AccountGroupPriceList__c createInsertTestAccountGroupPriceList(ccrz__E_AccountGroup__c accountGroup, ccrz__E_PriceList__c priceList) {        ccrz__E_AccountGroupPriceList__c accountGroupPriceList = new ccrz__E_AccountGroupPriceList__c(                ccrz__AccountGroup__c = accountGroup.Id,                ccrz__Pricelist__c = priceList.Id,                ccrz__StartDate__c = System.today().addYears(-1),                ccrz__Enable__c = true        );
        insert accountGroupPriceList;
        return accountGroupPriceList;
    }    
    /**     * @description Creates and inserts price list items.     */    
    public static void createInsertPriceListItems(List<ccrz__E_Product__c> products, ccrz__E_PriceList__c pricelist) {        
        List<ccrz__E_PriceListItem__c> items = new List<ccrz__E_PriceListItem__c>();
        for (ccrz__E_Product__c product : products) {            
            ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c(                    
                ccrz__Price__c = TEST_PRODUCT_PRICE,                    
                ccrz__Product__c = product.Id,                    
                ccrz__Pricelist__c = pricelist.Id,                    
                ccrz__StartDate__c = System.today().addYears(-1));

            items.add(priceListItem);
        }        
        insert items;
    }    
    /**     * @description Creates and Returns the specified number of CC products.     */    
    public static List<ccrz__E_Product__c> createInsertTestProducts(Integer size) {
        List<Product2> product2List = new List<Product2>();
        List<ccrz__E_Product__c> ccProducts = new List<ccrz__E_Product__c>();
        for (Integer i = 0; i < size;i++) {            
            Product2 p1 = new Product2(
                Name = TEST_SKU + i,
                Description = 'TestProduct1',
                ProductCode = TEST_SKU + i,
                Sync_Product_To_B2B__c = true,
                IsActive = true);
            product2List.add(p1);
        }        
        
        insert product2List;

        //Checking if SKU syncing is enabled.  If disabled,
        //we then need to create the B2B CCProduct records
        //manually and associate it a Product2 record
        CPQB2BConnector connector = new CPQB2BConnector();
        if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
            for (Integer i = 0; i < size;i++) {            
                ccrz__E_Product__c product = new ccrz__E_Product__c(                    
                    Name = TEST_SKU + i,                    
                    ccrz__SKU__c = TEST_SKU + i,                    
                    ccrz__ProductStatus__c = PRODUCT_STATUS_RELEASED,                    
                    ccrz__ProductType__c = PRODUCT_TYPE_PRODUCT,                    
                    ccrz__Storefront__c = TEST_STOREFRONT,                    
                    ccrz__ShortDesc__c = TEST_SKU,                    
                    ccrz__ShortDescRT__c = TEST_SKU,                    
                    ccrz__StartDate__c = System.today().addYears(-1),                    
                    ccrz__EndDate__c = System.today().addYears(+1),                    
                    ccrz__ShippingWeight__c = 1,
                    Source_Product__c = product2List[i].Id);
                
                ccProducts.add(product);
            }        
            insert ccProducts;
        }
        else{
            Set<Id> resultIds = (new Map<Id,SObject>(product2List)).keySet();
            ccProducts = [SELECT 
                            Id, 
                            Name, 
                            ccrz__SKU__c, 
                            ccrz__ProductStatus__c, 
                            ccrz__ProductType__c, 
                            ccrz__Storefront__c,
                            ccrz__ShortDesc__c,
                            ccrz__ShortDescRT__c,
                            ccrz__StartDate__c,
                            ccrz__EndDate__c,
                            ccrz__ShippingWeight__c 
                        FROM ccrz__E_Product__c 
                        WHERE Source_Product__c IN :resultIds];
        }
        return ccProducts;
    }    
    /**     * @description Creates a test user.     */    
    public static User createDefaultUser(Contact contact) {        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'B2B Customer Community Plus User' LIMIT 1];
        User u = new User(                
            LastName = 'SMITH',                
            FirstName = 'JOHN',                
            Alias = 'main',                
            Email = 'testuser@testfactory.com',                
            Phone = '1234567890',                
            Username = 'testuser@testfactory.com.' + Math.random(),                
            TimeZoneSidKey = 'Europe/Berlin',                
            LanguageLocaleKey = 'en_US',                
            EmailEncodingKey = 'UTF-8',                
            LocaleSidKey = 'en_US',                
            ContactId = contact.Id,                
            ProfileId = profile.Id);
        insert u;
        return u;
    }    
    /**     * @description Creates a test contact.     */    
    public static Contact createInsertDefaultContact(Account account) {        
        Contact contact = new Contact(                
            AccountId = account.Id,                
            FirstName = 'Default Contact',                
            LastName = 'Default Contact',                
            Email = 'defaultcontact@domain.com',               
            MailingStreet = 'testMailingStreet',                
            MailingPostalCode = '90210',                
            MailingCity = 'testMailingCity');

        insert contact;
        return contact;
    }    
    /**     * @description Creates Account, Account group, Users, PriceLists, Products, PriceListItems.     */    
    public static Map<String, Object> setupAccountContactUser(Boolean createParentAccount) {        
        
        initCCSettings();
        
        Account parentAccount;
        Contact parentContact;
        User parentUser;
        Account childAccount;
        Contact childContact;
        User childUser;
        
        //Account/Contact/User details        
        ccrz__E_AccountGroup__c accountGroup = createInsertTestAccountGroup();
        if (createParentAccount) {            
            parentAccount = createInsertTestAccount(accountGroup, true, null);
            childAccount = createInsertTestAccount(accountGroup, false, parentAccount);
            parentContact = createInsertDefaultContact(parentAccount);
            parentUser = createDefaultUser(parentContact);
        } else {            
            childAccount = createInsertTestAccount(accountGroup, false, null);
        }      
        
        childContact = createInsertDefaultContact(childAccount);
        childUser = createDefaultUser(childContact);
        
        //PriceLists        
        ccrz__E_PriceList__c pricelist = createInsertTestPricelist();
        createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        //Products and PriceListItems        
        List<ccrz__E_Product__c> products = createInsertTestProducts(2);
        createInsertPriceListItems(products, pricelist);
        return new Map<String, Object>{                
            TEST_PARENT_ACCOUNT => parentAccount,                
            TEST_CHILD_ACCOUNT => childAccount,               
            TEST_CONTACT => childContact,                
            TEST_PARENT_ACC_USER => parentUser,                
            TEST_CHILD_ACC_USER => childUser,                
            TEST_PRODUCTS => products};
    }    
    
    /**     
     * @description Creates a cart along with shipping and billing addresses.  
    */
    public static ccrz__E_Cart__c createCart(Boolean setBillingAndShippingAddress, Boolean sameAddressAsAccount, Map<String, Object> testData) {        
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        if (setBillingAndShippingAddress) {            
            Map<String, Object> billingAddress = new Map<String, Object> ();
            Map<String, Object> shippingAddress = new Map<String, Object> ();
            if (sameAddressAsAccount) {                
                billingAddress.put(ADDRESS_FIRSTLINE, PARENT_BILL_STREET);
                billingAddress.put(CITY, PARENT_BILL_CITY);
                billingAddress.put(STATE, PARENT_BILL_STATE);
                billingAddress.put(COUNTRY, PARENT_BILL_COUNTRY);
                billingAddress.put(POSTAL_CODE, PARENT_BILL_POSTAL_CODE);
                shippingAddress.put(ADDRESS_FIRSTLINE, CHILD_SHIP_STREET);
                shippingAddress.put(CITY, CHILD_SHIP_CITY);
                shippingAddress.put(STATE, CHILD_SHIP_STATE);
                shippingAddress.put(COUNTRY, CHILD_SHIP_COUNTRY);
                shippingAddress.put(POSTAL_CODE, CHILD_SHIP_POSTAL_CODE);
            } else {                
                billingAddress.put(ADDRESS_FIRSTLINE, TEST_STREET);
                billingAddress.put(CITY, TEST_CITY);
                billingAddress.put(STATE, TEST_STATE);
                billingAddress.put(COUNTRY, TEST_COUNTRY);
                billingAddress.put(POSTAL_CODE, TEST_POSTAL_CODE);
                shippingAddress.put(ADDRESS_FIRSTLINE, TEST_STREET);
                shippingAddress.put(CITY, TEST_CITY);
                shippingAddress.put(STATE, TEST_STATE);
                shippingAddress.put(COUNTRY, TEST_COUNTRY);
                shippingAddress.put(POSTAL_CODE, TEST_POSTAL_CODE);
            }            
            String billingAddressSFID = insertContactAddress(billingAddress);
            String shippingAddressSFID = insertContactAddress(shippingAddress);
            cart.ccrz__Account__c = ((Account) testData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;
            cart.ccrz__Contact__c = ((Contact) testData.get(cc_TestDataFactory.TEST_CONTACT)).Id;
            cart.ccrz__User__c = ((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;
            cart.ccrz__Storefront__c = TEST_STOREFRONT;
            cart.ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE;
            cart.ccrz__BillTo__c = billingAddressSFID;
            cart.ccrz__ShipTo__c = shippingAddressSFID;
        }        
        insert cart;
        return cart;
    }   
    
    /**     
     * * @description Inserts a CC Contact address.     
     */    
    public static String insertContactAddress(Map<String, Object> address) {        
        String addressSFID;
        Map<String, Object> addressCreateResult = 
                ccrz.ccAPIAddress.createAddress(new Map<String, Object>{               
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,                
                    ccrz.ccApiAddress.ADDRESSLIST => new List<Map<String, Object>>{address}});
        
        if (addressCreateResult != null && (Boolean) addressCreateResult.get(ccrz.ccApi.SUCCESS)) {            
            List<String> addressList = (List<String>) addressCreateResult.get(ccrz.ccApiAddress.ADDRESSIDLIST);
            if (addressList != null && addressList.size() > 0) {                
                addressSFID = addressList[0];
            }        
        }        
        return addressSFID;
    }    
    
    /**     
     * @description Creates and inserts a storedPayment record associated with the passed in Account.     
    */    
    public static ccrz__E_StoredPayment__c createInsertStoredPayment(Account currAccount) {        
        ccrz__E_StoredPayment__c newStoredPayment = new ccrz__E_StoredPayment__c();
        newStoredPayment.Name = 'Test payment';
        newStoredPayment.ccrz__DisplayName__c = 'ACH Net 30';
        newStoredPayment.ccrz__StartDate__c = System.today();
        newStoredPayment.ccrz__EndDate__c = System.today().addDays(3);
        newStoredPayment.ccrz__AccountType__c = 'po';
        newStoredPayment.ccrz__Account__c = currAccount.Id;
        newStoredPayment.ccrz__Enabled__c = true;
        newStoredPayment.ccrz__Storefront__c = TEST_STOREFRONT;
        insert newStoredPayment;
        return newStoredPayment;
    }

    public static List<ccrz__E_ShippingRate__c> createInsertShippingRates() {        
        List<ccrz__E_ShippingRate__c> testShippingRateList = new List<ccrz__E_ShippingRate__c>();
        ccrz__E_ShippingRate__c shipRate1 = new ccrz__E_ShippingRate__c();
        shipRate1.ccrz__Shipper__c = 'Shipper1';
        shipRate1.Name = 'Ground';
        shipRate1.ccrz__Ground__c = true;
        shipRate1.ccrz__ShippingRate__c = 10;
        shipRate1.ccrz__Storefront__c = TEST_STOREFRONT;
        shipRate1.ccrz__MinWeight__c = 0;
        shipRate1.ccrz__MaxWeight__c = 9999;
        shipRate1.ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE;
        shipRate1.ccrz__Sequence__c = 1;
        
        ccrz__E_ShippingRate__c shipRate2 = new ccrz__E_ShippingRate__c();
        shipRate2.ccrz__Shipper__c = 'Shipper2';
        shipRate2.Name = 'Ground';
        shipRate2.ccrz__ShippingRate__c = 10;
        shipRate2.ccrz__Storefront__c = TEST_STOREFRONT;
        shipRate2.ccrz__MinWeight__c = 0;
        shipRate2.ccrz__MaxWeight__c = 9999;
        shipRate2.ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE;
        shipRate2.ccrz__Sequence__c = 2;
        testShippingRateList.add(shipRate1);
        testShippingRateList.add(shipRate2);
        
        insert testShippingRateList;
        return testShippingRateList;
    }
}