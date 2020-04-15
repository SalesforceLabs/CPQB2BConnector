/**
* @author Amil Abdallah
* @date 3-08-2020
*
* @see CPQB2BMappingUtils
* @description CPQ Quote Service class used by CPQB2B MappingService for Quote creation/calculation
*/
public inherited sharing class CPQB2BQuoteService {

    CPQB2BMappingUtils mapUtil;

    public CPQB2BQuoteService() {
        mapUtil = new CPQB2BMappingUtils();
    }

    /*******************************************************************************************************
    * @description Returns a CPQ Quote for the given cart record.  The Quote's associated account and cart
    * fields are populated from B2B cart record. The custom cart to quote status is retrieve and assigned
    * to the Quote's SBQQ__Status__c field.
    * @param ccrz__E_Cart__c cart
    * @return  SBQQ__Quote__c
    */
    public SBQQ__Quote__c getNewQuoteFromCart(ccrz__E_Cart__c cart){
        //retrieves custom status to set on Quote Status field
        String cartToQuoteStatus = CPQB2BMappingSelector.getCustomQuoteStatus();
        CPQB2BPriceBookSelector pbs = new CPQB2BPriceBookSelector();
        Pricebook2 standardPriceBook = pbs.getStandardPriceBook();

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sync_Quote_To_B2B__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = cart.ccrz__Account__c;
        quote.B2B_Source__c = cart.Id;
        quote.SBQQ__Status__c = cartToQuoteStatus;
        quote.SBQQ__PricebookId__c = standardPriceBook.Id;
        quote.Quote_Additional_Details__c = cart.Quote_Additional_Details__c;
        insert quote;

        return quote;
    }

    /*******************************************************************************************************
    * @description Calculates the provided quote record through use of the CPQAPI QuoteCalculator
    * @param SBQQ__Quote__c quote
    */
    public void calculateQuote(SBQQ__Quote__c quote){

        Id cartId = quote.B2B_Source__c;
        Id accountId = quote.SBQQ__Account__c;

        //Get the list of ccProduct Ids associated to the cart from which
        //the quote was generated
        CPQB2BMappingUtils mapUtil = new CPQB2BMappingUtils();
        List<Id> ccProductIds = mapUtil.getCCProductIdsFromCartId(cartId);

        //Instantiate instance of CPQAPI and associate the quote record
        CPQAPI api = new CPQAPI();
        api.model = api.calc.read(quote.Id);

        Map<Id,CPQB2BProductLineItem> productLineItemMap = mapUtil.getProductLineItemMap(cartId, accountId);

        //Generates a list of ProductModel records used by the CPQAPI to generate QuoteLines
        List<CPQAPI.ProductModel> productModels = new List<CPQAPI.ProductModel>();

        String currencyIsoCode;

        //Check if org is using multi-currency, if true then we grab the correct
        //currency iso code from the user record (User.ccrz__CC_CurrencyCode__c)
        //else we get the org default currency
        if (UserInfo.isMultiCurrencyOrganization()) {
            CPQB2BUserSelector userSelector = new CPQB2BUserSelector();
            User u = (User) userSelector.getRecordById(UserInfo.getUserId());
            currencyIsoCode = u.ccrz__CC_CurrencyCode__c;
        }
        else{
            currencyIsoCode = UserInfo.getDefaultCurrency();
        }

        for(CPQB2BProductLineItem pli : productLineItemMap.values()){
            CPQAPI.ProductModel productModel = CPQAPI.readProduct(pli.product2Id,pli.pricebookId, currencyIsoCode);
            productModels.add(productModel);
        }

        //Add the list of productModels to the CPQAPI quote instance
        api.model = CPQAPI.addProduct(api.model,productModels,0);

        for(CPQAPI.QuoteLineModel quoteLine: api.model.lineItems){
            Id productId = quoteLine.record.SBQQ__Product__c;
            CPQB2BProductLineItem pli = productLineItemMap.get(productId);
            quoteLine.record.SBQQ__ListPrice__c = pli.price;
            quoteLine.record.SBQQ__Quantity__c = pli.quantity;
        }

        //Calculates the quote for the provided products
        api.calc.calculate(api.model,'CPQB2BQuoteCallback');
    }

    /**
     * @description This creates a new quote from a CC Order. Quotes should be primary and associated to
     * to the order via the B2B_Source_Order_id. SBQQ__PricebookId__c is required for quote lines to be generated
     *
     * @param List<ccrz__E_Order__c> ccOrders
     * @return SBQQ__Quote__c quote
     */
    public SBQQ__Quote__c getNewQuoteFromOrder(ccrz__E_Order__c order, Id priceBookId, String customQuoteStatus) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sync_Quote_To_B2B__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = order.ccrz__Account__c;
        quote.B2B_Source_Order__c = order.Id;
        quote.SBQQ__PricebookId__c = priceBookId;
        quote.SBQQ__Status__c = customQuoteStatus;
        return quote;
    }

    /**
     * @description Calculate a list of quotes utilizing the CPQ API
     *
     * @param List<SBQQ__Quote__c> quotes
     */
     public void calculateQuotesFromOrders(List<SBQQ__Quote__c> quotes, Map<Id,List<CPQB2BProductLineItem>> orderProductLineItemMap) {
          //Get a list of the quote ids
          Map<Id, SBQQ__Quote__c> quotesMap = new Map<Id, SBQQ__Quote__c>();
          quotesMap.putAll(quotes);
          List<Id> quoteIds = new List<Id>(quotesMap.keySet());

          //Get a list of the CC Order Ids from the Quote
          List<Id> orderIds = new List<Id>();
          for(SBQQ__Quote__c quote : quotes) {
               orderIds.add(quote.B2B_Source_Order__c);
          }

          //Calculate each quote via the CPQ Api
          for (SBQQ__Quote__c quote : quotes) {
               List<CPQB2BProductLineItem> ccProductLineItems = new List<CPQB2BProductLineItem>();
               if (orderProductLineItemMap != null) {
                    ccProductLineItems = orderProductLineItemMap.get(quote.B2B_Source_Order__c);
               }

               calculateQuoteFromOrder(quote, ccProductLineItems);
               //Update the quote to be ordered so that it generates the order and order items
               quote.SBQQ__Ordered__c = true;
          }
          //Persist the quotes ordered checkbox
          update quotes;
     }


    /**
     * @description Calculate a list of quotes utilizing the CPQ API
     *
     * @param List<SBQQ__Quote__c> quotes
     * @param List<CPQB2BProductLineItem> ccProductLineItems
     */
     public void calculateQuoteFromOrder(SBQQ__Quote__c quote, List<CPQB2BProductLineItem> ccProductLineItems) {
          List<CPQAPI.ProductModel> productModels = new List<CPQAPI.ProductModel>();
          CPQAPI api = new CPQAPI();
          api.model = api.calc.read(quote.Id);

          Map<Id, CPQB2BProductLineItem> productLineItemMap = new Map<Id, CPQB2BProductLineItem>();
          for(CPQB2BProductLineItem ccProductLineItem : ccProductLineItems) {
               CPQAPI.ProductModel productModel = CPQAPI.readProduct(ccProductLineItem.Product2Id, quote.SBQQ__PricebookId__c, UserInfo.getDefaultCurrency());
               productModels.add(productModel);
               productLineItemMap.put(ccProductLineItem.Product2Id, ccProductLineItem);
          }

          api.model = CPQAPI.addProduct(api.model,productModels,0);

          for(CPQAPI.QuoteLineModel quoteLine: api.model.lineItems) {
               Id productId = quoteLine.record.SBQQ__Product__c;
               CPQB2BProductLineItem pli = productLineItemMap.get(productId);
               quoteLine.record.SBQQ__ListPrice__c = pli.price;
               quoteLine.record.SBQQ__Quantity__c = pli.quantity;
           }

          //Calculates the quote for the provided products
          api.calc.calculate(api.model,'CPQB2BQuoteCallback');
     }
}