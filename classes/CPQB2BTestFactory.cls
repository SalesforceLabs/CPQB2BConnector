/**
* @author Ashlee Zeigler
* @date 2-21-2020
*
*
* @description This is a test factory to create SObjects for test classes
*/
@isTest
public class CPQB2BTestFactory {

   /**
    * @description Create a test product
    * @param Name
    * @param ProductCode
    * @param ShouldSync
    * @param IsActive
    * @return Product2
    */
   public static Product2 createProduct(String name, String productCode, Boolean shouldSync, Boolean isActive) {
        Product2 p1 = new Product2();
        p1.Name = name;
        p1.ProductCode = productCode;
        p1.Sync_Product_To_B2B__c = shouldSync;
        p1.IsActive = isActive;
        return p1;
   }

    /**
    * @description Create a test product to sync that is active
    * @param Name
    * @param ProductCode
    * @return Product2
    */
   public static Product2 createSyncedProduct(String name, String productCode) {
        return createProduct(name, productCode, true, true);
   }

    /**
     * @description Create a list of test products
     * @param String name
     * @param String productCode
     * @param Boolean shouldSync
     * @param Boolean isActive 
     * @param Integer productCount
     * @return List<Product2> 
    */
   public static List<Product2> createProducts(String name, String productCode, Integer productCount, Boolean shouldSync, Boolean isActive) {
        List<Product2> products = new List<Product2>();
        for(Integer x = 0; x < productCount; x++){
            products.add(createProduct(name + x, productCode + x, shouldSync, isActive));
        }
        return products;
   }

    /**
    * @description Create a test product to sync that is active and synced
    * @param Name
    * @param ProductCode
    * @param ProductCount
    * @return Product2
    */
   public static Product2 createSyncedProducts(String name, String productCode, Integer productCount) {
        return createProduct(name, productCode, true, true);
   }

    /**
     * @description Create a test CCProduct based off of values from Product2 
     * @param  Product2 product
     * @return ccrz__E_Product__c
    */
   public static ccrz__E_Product__c createCCProduct(Product2 product) {
        ccrz__E_Product__c ccProduct = new ccrz__E_Product__c();
        ccProduct.Name = product.Name;
        ccProduct.ccrz__SKU__c = product.ProductCode;
        ccProduct.Source_Product__c = product.Id;
        return ccProduct;
   }

    /**
     * @description Create a non standard pricebook
     * @return PriceBook2
    */
   public static PriceBook2 createPriceBook() {
       return createPriceBook('PB Name', 'PB Description');
   }

    /**
     * @description Create a non standard pricebook
     * @param Name
     * @param Description
     * @return PriceBook2
    */
   public static PriceBook2 createPriceBook(String name, String description) {
        PriceBook2 pb = new PriceBook2 (
            Name = name,
            Description = description,
            IsActive = true
        );
        return pb;
   }

    /**
     * @description Create the standard price book
     * @return PriceBook2
    */
   public static PriceBook2 getStandardPriceBook() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        return standardPricebook;
   }

    /**
     * @description Create a test PriceBookEntry record from a priceBook and product
     * @param  Id priceBookId
     * @param  Id productId
     * @param  Decimal unitPrice
     * @return PriceBookEntry
    */
   public static PriceBookEntry createPriceBookEntry(Id priceBookId, Id productId, Decimal unitPrice) {
     PriceBookEntry pbe = new PriceBookEntry();
     pbe.Pricebook2Id = priceBookId;
     pbe.Product2Id = productId;
     pbe.UnitPrice = unitPrice;
     pbe.IsActive = true;
     if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
          List<SObject> currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
          if (!currencyTypes.isEmpty()) {
               pbe.put('CurrencyIsoCode', (String)currencyTypes[0].get('isoCode'));
          }
     }
     return pbe;
   }

    /**
     * @description Create a test SBQQ__Quote__c record based on an account and indicate whether it should sync to B2B
     * @param  Id accountId
     * @param  Boolean syncEnabled
     * @param  Boolean isPrimary
     * @param  Boolean isApproved
     * @return SBQQ__Quote__c
    */
   public static SBQQ__Quote__c createQuote(Id accountId, Boolean syncEnabled, Boolean isPrimary, Boolean isApproved) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sync_Quote_To_B2B__c = syncEnabled;
        quote.SBQQ__Primary__c = isPrimary;
        if (isApproved) {
            quote.SBQQ__Status__c = 'Approved';
        } else {
            quote.SBQQ__Status__c = 'Draft';
        }
        quote.SBQQ__Account__c = accountId;
        if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
            List<SObject> currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
            if (!currencyTypes.isEmpty()) {
                quote.put('CurrencyIsoCode', (String)currencyTypes[0].get('isoCode'));
            }
        }
        return quote;
   }

     /**
     * Create a test SBQQ__Quote__c record based on an account and indicate whether it should sync to B2B
     * @param  Id accountId
     * @return SBQQ__Quote__c
    */
   public static SBQQ__Quote__c createQuoteThatShouldSync(Id accountId) {
        return createQuote(accountId, true, true, true);
   }

    /**
     * @description Create a test SBQQ__QuoteLine__c record for a quote and a product
     * @param  Id quoteId
     * @param  Id productId
     * @return SBQQ__QuoteLine__c
    */
   public static SBQQ__QuoteLine__c createQuoteLine(Id quoteId, Id productId, Decimal netPrice) {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quoteId;
        quoteLine.SBQQ__NetPrice__c = netPrice;
        quoteLine.SBQQ__Product__c = productId;
        return quoteLine;
   }

    /**
     * @description Create a test ccrz__E_PriceListItem__c record for a quoteline, CC Product, and CC PriceList
     * @param  Id quoteLine
     * @param  Id productId
     * @param  Id priceListId
     * @return ccrz__E_PriceListItem__c
    */
   public static ccrz__E_PriceListItem__c createPriceListItemFromQuoteLine(SBQQ__QuoteLine__c quoteLine, Id productId, Id priceListId) {
        ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
        pli.Quote_Line__c = quoteLine.Id;
        pli.ccrz__Price__c = quoteLine.SBQQ__NetPrice__c;
        pli.ccrz__Pricelist__c = priceListId;
        pli.ccrz__Product__c = productId;
        return pli;
   }

    /**
     * @description Create a test ccrz__E_PriceListItem__c record for a price book entry, CC Product, and CC PriceList
     * @param  Id priceBookEntryId
     * @param  Id ccProductId
     * @param  Id priceListId
     * @return ccrz__E_PriceListItem__c
    */
    public static ccrz__E_PriceListItem__c createPriceListItemFromPriceBookEntry(PriceBookEntry priceBookEntryId, Id ccProductId, Id priceListId) {
        ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
        pli.Source_PriceBookEntry_Id__c = priceBookEntryId.Id;
        pli.ccrz__Price__c = priceBookEntryId.UnitPrice;
        pli.ccrz__Pricelist__c = priceListId;
        pli.ccrz__Product__c = ccProductId;
        if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
          List<SObject> currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
          if (!currencyTypes.isEmpty()) {
               pli.put('CurrencyIsoCode', (String)currencyTypes[0].get('isoCode'));
          }
     }
      return pli;
   }

    /**
     * @description Create a test ccrz__E_PriceList__c record for a price book entry
     * @param Id priceBookId
     * @param String name
     * @return ccrz__E_PriceList__c
    */
   public static ccrz__E_PriceList__c createPriceListFromPriceBook(Id priceBookId, String name) {
        ccrz__E_PriceList__c priceList = createPriceList(name);
        priceList.Source_Price_Book__c = priceBookId;
        return priceList;
   }

    /**
    * @description Create a test ccrz__E_PriceList__c record for a price book entry
    * @param  Id accountGroupId
    * @param String name
    * @return ccrz__E_PriceList__c
    */
   public static ccrz__E_PriceList__c createPriceListFromAccountGroup(Id accountGroupId, String name) {
        ccrz__E_PriceList__c priceList = createPriceList(name);
        return priceList;
   }
   
    /**
    * @description Create a test ccrz__E_PriceList__c record
    * @param String name
    * @return ccrz__E_PriceList__c
    */
   public static ccrz__E_PriceList__c createPriceList(String name) {
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c();
        List<SObject> currencyTypes = new List<SObject>();
        if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
           currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
        }
        if (!currencyTypes.isEmpty()) {
             priceList.ccrz__CurrencyISOCode__c = (String)currencyTypes[0].get('IsoCode');
        } else {
            priceList.ccrz__CurrencyISOCode__c = UserInfo.getDefaultCurrency();
        }
        priceList.Name = name;
        priceList.ccrz__Enabled__c = true;
        priceList.ccrz__StartDate__c = Date.newInstance(2020, 3, 07);
        priceList.ccrz__EndDate__c = Date.newInstance(2020, 9, 07);
        return priceList;
     }

    /**
    * @description Create a test ccrz__E_AccountGroupPriceList__c record
    * @param Id priceListId
    * @param Id accountGroupId
    * @return ccrz__E_AccountGroupPriceList__c
    */
     public static ccrz__E_AccountGroupPriceList__c createAccountGroupPriceList(Id priceListId, Id accountGroupId) {
          ccrz__E_AccountGroupPriceList__c ccAccountGroupPriceList = new ccrz__E_AccountGroupPriceList__c();
          ccAccountGroupPriceList.ccrz__Pricelist__c = priceListId;
          ccAccountGroupPriceList.ccrz__AccountGroup__c = accountGroupId;
          return ccAccountGroupPriceList;
     }

     /**
     * @description Create a test order
     * @param Boolean shouldSync
     * @param Id accountId
     * @param Id contactId
     * @param Id priceBookId
     * @return Order
     */
     public static Order createOrder(Boolean shouldSync, Id accountId, Id contactId, Id priceBookId) {
          Order o = new Order();
          o.Sync_to_B2B__c = shouldSync;
          o.AccountId = accountId;
          o.Name = 'Order Name';
          o.EffectiveDate = Date.newInstance(2012, 2, 20);
          o.Status = 'Draft';
          o.CustomerAuthorizedById = contactId;
          if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
               List<SObject> currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
               if (!currencyTypes.isEmpty()) {
                    o.put('CurrencyIsoCode', (String)currencyTypes[0].get('isoCode'));
               }
          }
          o.PriceBook2Id = priceBookId;
          return o;
     }

     /**
     * @description Create a list of test orders 
     * @param  Integer ordercount
     * @param Boolean shouldSync
     * @param Id accountId
     * @param Id contactId
     * @param Id priceBookId
     * @return List<Order>
    */
    public static List<Order> createOrders(Integer orderCount, Boolean shouldSync, Id accountId, Id contactId, Id priceBookId) {
         List<Order> orders = new List<Order>();
         for(Integer x = 0; x < orderCount; x++){
              orders.add(createOrder(shouldSync, accountId, contactId, priceBookId));
          }
          return orders;
     }

     /**
     * @description Create a test cc order
     * @param Id accountId
     * @return ccrz__E_Order__c
     */
     public static ccrz__E_Order__c createCCOrder(Id accountId) {
          return createCCOrder(accountId, false);
     }

     /**
     * @description Create a test cc order
     * @param Id accountId
     * @param Boolean shouldSync
     * @return ccrz__E_Order__c
     */
    public static ccrz__E_Order__c createCCOrder(Id accountId, Boolean shouldSync) {
          ccrz__E_Order__c o = new ccrz__E_Order__c();
          o.ccrz__Account__c = accountId;
          o.ccrz__OrderDate__c = Date.newInstance(2012, 12, 12);
          o.ccrz__Name__c = 'Order Name';
          o.ccrz__OrderStatus__c = 'Draft';
          o.Sync_to_CPQ__c = shouldSync;

          if (!UserInfo.isMultiCurrencyOrganization()) {
               o.ccrz__CurrencyISOCode__c = UserInfo.getDefaultCurrency();
          } else {
               List<SObject> currencyTypes = new List<SObject>();
               currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');

               if (currencyTypes != null && !currencyTypes.IsEmpty()) {
                    o.ccrz__CurrencyISOCode__c = (String)currencyTypes[0].get('IsoCode');
               }
          }
          return o;
     }

     /**
     * @description Create a list of test orders 
     * @param  Integer ordercount
     * @param Id accountId
     * @return List<Order>
    */
    public static List<ccrz__E_Order__c> createCCOrders(Integer orderCount, Id accountId, Boolean shouldSync) {
         List<ccrz__E_Order__c> orders = new List<ccrz__E_Order__c>();
         for(Integer x = 0; x < orderCount; x++){
              orders.add(createCCOrder(accountId, shouldSync));
          }
          return orders;
     }

     /**
     * @description Create a test order item
     * @param Id orderId
     * @param Id Product2Id
     * @param Id PriceBookEntryId2
     * @return OrderItem
     */
    public static OrderItem createOrderItem(Id orderId, Id product2Id, Id priceBookEntryId) {
          OrderItem oi = new OrderItem();
          oi.OrderId = orderId;
          oi.Product2Id = product2Id;
          oi.UnitPrice = 100;
          oi.Quantity = 2;
          oi.PriceBookEntryId = priceBookEntryId;
          return oi;
     }

      /**
     * @description Create a test cc order item
     * @param Id ccOrderId
     * @param Id ccProductId
     * @return ccrz__E_OrderItem__c
     */
     public static ccrz__E_OrderItem__c createCCOrderItem(Id ccOrderId, Id ccProductId) {
          ccrz__E_OrderItem__c ccOrderItem = new ccrz__E_OrderItem__c();
          ccOrderItem.ccrz__Order__c = ccOrderId;
          ccOrderItem.ccrz__ItemStatus__c = 'Available';
          ccOrderItem.ccrz__OrderLineType__c = 'Major';
          ccOrderItem.ccrz__OriginalItemPrice__c = 100;
          ccOrderItem.ccrz__OriginalQuantity__c = 2;
          ccOrderItem.ccrz__Quantity__c = 2;
          ccOrderItem.ccrz__Product__c = ccProductId;
          ccOrderItem.ccrz__Price__c = 100;
          ccOrderItem.ccrz__SubAmount__c = 100;
          return ccOrderItem;
     }

     /**
     * @description Create a test portal user
     * @param Contact c
     * @return User
     */
     public static User createTestPortalUser(Contact c) {
          UserLicense li = [SELECT Id FROM UserLicense where name = 'Customer Community Plus'];
          Profile p = [SELECT Id FROM Profile WHERE UserLicenseId = : li.Id Limit 1];

          User user = new User();
          user.ProfileID = p.id;
          user.EmailEncodingKey = 'ISO-8859-1';
          user.LanguageLocaleKey = 'en_US';
          user.TimeZoneSidKey = 'America/New_York';
          user.LocaleSidKey = 'en_US';
          user.FirstName = 'first';
          user.LastName = 'last';
          user.Username = 'test@test.com';   
          user.CommunityNickname = 'testUser123';
          user.Alias = 't1';
          user.Email = 'no@email.com';
          user.IsActive = true;
          user.ContactId = c.Id;
        
         return user;
     }

     /**
     * @description Create a test portal user
     * @return User
     */
     public static User createCPQB2BAdminUser(Boolean isSystemAdmin) {
          Profile p;
          if (isSystemAdmin) {
               p = [SELECT Id FROM Profile where name = 'System Administrator' Limit 1];
          } else {
               p = [SELECT Id FROM Profile where name = 'Standard User' Limit 1];
          }

          UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];

          User user = new User();
          user.ProfileID = p.id;
          user.UserRoleId = r.id;
          user.EmailEncodingKey = 'ISO-8859-1';
          user.LanguageLocaleKey = 'en_US';
          user.TimeZoneSidKey = 'America/New_York';
          user.LocaleSidKey = 'en_US';
          user.FirstName = 'first';
          user.LastName = 'last';
          user.Username = 'test@test.com' + Math.random();   
          user.Alias = 't1';
          user.Email = 'no@email.com';
          user.IsActive = true;

          if (UserInfo.isMultiCurrencyOrganization()) {
               List<SObject> currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
               if (!currencyTypes.isEmpty()) {
                    user.ccrz__CC_CurrencyCode__c = (String)currencyTypes[0].get('isoCode');
               }
          }

          insert user;

          PermissionSet psCPQB2B = [SELECT Id FROM PermissionSet WHERE Name = 'CPQ_B2B_Connector_Admin'];
          insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psCPQB2B.Id);   

          PermissionSet psB2B = [SELECT Id FROM PermissionSet WHERE Name = 'B2BCommerceAdmin'];
          if (psB2B != null) {
               insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psB2B.Id);   
          }

          PermissionSet psCPQ = [SELECT Id FROM PermissionSet WHERE Name = 'SteelBrickCPQAdmin'];
          if (psCPQ != null) {
               insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psCPQ.Id);   
          }

          return user;
     }
     
     /**
     * @description Create a test CC Cart
     * @return ccrz__E_Cart__c
     */
     public static ccrz__E_Cart__c createCCCart(Map<String, Object> b2bTestData) {          
          Map<String, Object> cartValidateResponse;

          String currCartENCID;
          String currCartSFID;

          ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();        
          ctx.storefront = (String) b2bTestData.get(cc_TestDataFactory.TEST_STOREFRONT);        
          ctx.portalUserId = ((User) b2bTestData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;        
          ctx.effAccountId = ((Account) b2bTestData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;        
          ccrz.cc_CallContext.init(ctx);
          
          Map<String, Object> addToCartResult = ccrz.ccApiCart.addTo(new Map<String, Object>{                
               ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,                
               ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>>{                        
                    new Map<String, Object> {                                
                    ccrz.ccApiCart.LINE_DATA_SKU => cc_TestDataFactory.TEST_SKU + 1,                                
                    ccrz.ccApiCart.LINE_DATA_QUANTITY => 2                        
                    }                
               }        
          });        
          
          currCartENCID = (String) addToCartResult.get(ccrz.ccApiCart.CART_ENCID);
          
          cartValidateResponse = ccrz.ccApiCart.validate(new Map<String, Object>{                
               ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,                
               ccrz.ccAPICart.CART_ENCID => currCartENCID        
          });

          String cartStatus = CPQB2BMappingSelector.getCustomCartStatus();
          ccrz__E_Cart__c ccCart = [Select Id,Name, ccrz__EncryptedId__c, ccrz__Account__c,ccrz__Storefront__c FROM ccrz__E_Cart__c LIMIT 1];
          
          return ccCart;
     }
}