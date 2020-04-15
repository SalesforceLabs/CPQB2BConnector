/**
* @author Ashlee Zeigler
* @date 2-25-2020
* @see CPQB2BLogger
* @see CPQB2BMappingUtils
* @description Service for CC Price Lists and related objects
*/
public class CPQB2BCCPriceListService {
    public CPQB2BLogger logger {get;set;}
    public String triggerEvent {get;set;}
    public CPQB2BMappingUtils mappingUtils {get;set;}

    public CPQB2BCCPriceListService(String triggerEvent) {
        this.triggerEvent = triggerEvent;
        this.logger = new CPQB2BLogger();
        this.mappingUtils = new CPQB2BMappingUtils(triggerEvent);
    }

    /**
     * @description This selects the accounts by ids and updates the appropriate account group
     * @param List<Id> accountIds
     * @param Map<Id,ccrz__E_AccountGroup__c> accountGroupMap
     * @return Map<Id, Account> Map of Account Id to Account
     */
    public Map<Id, Account> setAccountGroupAccounts(Map<Id,ccrz__E_AccountGroup__c> accountGroupMap) {
        List<Id> accountGroupIds = new List<Id>();
        for (ccrz__E_AccountGroup__c ag : accountGroupMap.values()) {
            accountGroupIds.add(ag.Id);
        }

        //Select all of the accounts by Ids that were pulled from the quote
        List<Account> accounts = new CPQB2BAccountSelector().getAccountsByIds(accountGroupMap.keySet());
        //Map: Account Id => Account
        Map<Id, Account> accountMap = new Map<Id, Account>(); 
        Boolean hasAccountsToUpdate = false;  
        for (Account acc : accounts) {
            if (!accountGroupMap.IsEmpty()) {
                //Get the account group by name
                ccrz__E_AccountGroup__c accountGroup = accountGroupMap.get(acc.Id);
                if (accountGroup != null) {
                    //Associate the account to the account group
                    acc.ccrz__E_AccountGroup__c = accountGroup.Id;
                    hasAccountsToUpdate = true;
                }
            }
            accountMap.put(acc.id, acc);
        }

        if (hasAccountsToUpdate == true) {
            //update the accounts to associate the account groups
            update accounts;
            List<Database.UpsertResult> dsrs;
            try {
                dsrs = Database.Upsert(accounts, false);
                logger.log(CPQB2BProcessType.Pricing.name(), this.triggerEvent, dsrs, accounts);        
            } catch (Exception e) {
                logger.log(CPQB2BProcessType.Pricing.name(), this.triggerEvent, e, accounts);          
            } finally{
                logger.write();
            }
        }
        return accountMap;
    }

   /**
     * @description This selects the accounts by ids and updates the appropriate account group
     * @param List<Id> accountIds
     * @param Map<Id,ccrz__E_AccountGroup__c> accountGroupMap
     * @return Map<Id, Account> Map of Account Id to Account
     */
    public Map<Id, List<ccrz__E_PriceList__c>> getPriceListsByAccountGroup(Map<Id,ccrz__E_AccountGroup__c> accountGroupMap) {
        List<Id> accountGroupIds = new List<Id>();
        for (ccrz__E_AccountGroup__c ag : accountGroupMap.values()) {
            accountGroupIds.add(ag.Id);
        }

        return getPriceListsByAccountGroup(accountGroupIds);
    }

       /**
     * @description This selects the accounts by ids and updates the appropriate account group
     * @param List<Id> accountIds
     * @param Map<Id,ccrz__E_AccountGroup__c> accountGroupMap
     * @return Map<Id, Account> Map of Account Id to Account
     */
    public Map<Id, List<ccrz__E_PriceList__c>> getPriceListsByAccountGroup(List<Id> accountGroupIds) {
        //Create Map: Account Group Id -> List of CC Price Lists
        Map<Id, List<ccrz__E_PriceList__c>> agCCPriceListMap = new Map<Id, List<ccrz__E_PriceList__c>>();
        List<ccrz__E_AccountGroupPriceList__c> ccAccountGroupPriceLists = new CPQB2BCCAccountGrpPriceListSelector().getCCAccountGroupPriceListsByAccountGroupIds(accountGroupIds);
        for (ccrz__E_AccountGroupPriceList__c accrGrpPriceList : ccAccountGroupPriceLists) {
            // It is possible for there to be multiple price lists for the account due to differences in currency
            if (agCCPriceListMap.containsKey(accrGrpPriceList.ccrz__AccountGroup__c)) {
                agCCPriceListMap.get(accrGrpPriceList.ccrz__AccountGroup__c).add(accrGrpPriceList.ccrz__Pricelist__r);
            } else {
                agCCPriceListMap.put(accrGrpPriceList.ccrz__AccountGroup__c, 
                new List<ccrz__E_PriceList__c> { accrGrpPriceList.ccrz__Pricelist__r });
            }
        }
        return agCCPriceListMap;
    }

     /**
     * @description This gets or creates the appropriate price list for a quote
     *  
     * @param List<SBQQ__Quote__c> quotes
     * @param Map<Id, Account> accountMap
     * @param Map<Id,ccrz__E_AccountGroup__c> accountToAccountGroupMap
     * @param Map<Id, List<ccrz__E_PriceList__c>> ccAccountGroupPriceListMap
     * @return Map<Id, Id> Quote Id -> Price List Id
     */
    public Map<Id, Id> getOrCreatePriceListIdsByQuoteIds(
        List<SBQQ__Quote__c> quotes, 
        Map<Id, Account> accountMap,
        Map<Id,ccrz__E_AccountGroup__c> accountToAccountGroupMap,
        Map<Id, List<ccrz__E_PriceList__c>> ccAccountGroupPriceListMap
    ) {
        Map<Id, SBQQ__Quote__c> accountGroupToQuoteMap = new Map<Id, SBQQ__Quote__c>(); 
        Map<Id, ccrz__E_PriceList__c> newCCPriceListMap = new Map<Id, ccrz__E_PriceList__c>(); 
        //Create a map from quote to price list so that the quote line
        //will be able to quickly find what it needs to associate to
        Map<Id, Id> quoteToPriceListMap = new Map<Id, Id>();
        List<ccrz__E_AccountGroupPriceList__c> ccAccountGroupPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
        for (SBQQ__Quote__c quote : quotes) {
            //Get the account for the quote
            Account acc = accountMap.get(quote.SBQQ__Account__c);
            if (acc == null) {
                logger.log(CPQB2BProcessType.Pricing.name(), quote.Id, null, this.triggerEvent, null, Label.CPQB2B_QuoteLine_Sync_No_Account);
                continue;
            }

            //Get the price list by the account group
            List<ccrz__E_PriceList__c> ccPriceLists = ccAccountGroupPriceListMap.get(acc.ccrz__E_AccountGroup__c);
            String currencyType;
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            //Populate the currency of price list from either the quote or by the default currency if a single currency org
            if (isMultiCurrency) {
                currencyType = (String)quote.get('CurrencyIsoCode');
            } else {
                currencyType = UserInfo.getDefaultCurrency();
            }

            ccrz__E_PriceList__c ccPriceList;
            //If there is only one price list, grab that price list
            if (ccPriceLists != null) {
                if (ccPriceLists.size()== 1) {
                    ccPriceList = ccPriceLists[0];
                } else {
                    //There is more than one price list for the account group, we need to find the matching one for the quote
                    for (ccrz__E_PriceList__c ccPl : ccPriceLists) {
                        //find the price list that matches the currency
                        if (ccPl.ccrz__CurrencyISOCode__c == currencyType) {
                            //Found the CC Price List, exit the loop
                            ccPriceList = ccPl;
                            break;
                        }
                    }
                }
            }

            //We didn't find a CC price list for the expected currency so we need to create it
            if (ccPriceList == null) {
                //Find the account group
                ccrz__E_AccountGroup__c accountGroup = accountToAccountGroupMap.get(quote.SBQQ__Account__c);

                //we will need to associate the CC Price List to the quote after insert, so this associates the account group 
                //to the quote so it can be easily queried after the records have been inserted
                accountGroupToQuoteMap.put(accountGroup.Id, quote);
                //Create the CC Account Group Price List and associate to the account group
                ccrz__E_AccountGroupPriceList__c agPriceList = new ccrz__E_AccountGroupPriceList__c();
                agPriceList.ccrz__AccountGroup__c = accountGroup.Id;
                //add it to a list to be saved off all at once.
                ccAccountGroupPriceLists.add(agPriceList);   

                //Create the Account Group and the Price List
                ccPriceList = createAccountGroupPriceList(accountGroup, currencyType);

                //Add it to a map so we can query the appropriate CCPriceList Id to set on the CC Acccount Group Price List record
                newCCPriceListMap.put(accountGroup.Id, ccPriceList);
            } else {       
                //Create a map to associate the quote to the pricelist
                quoteToPriceListMap.put(quote.Id, ccPriceList.Id);    
            }
        }

        logger.write();

        mappingUtils.performUpsert(CPQB2BProcessType.Pricing.name(), newCCPriceListMap.values());

        //Now that the CC Price Lists are saved we need to associate it to the CC Account Group Price List and the quote
        for (ccrz__E_AccountGroupPriceList__c agpl : ccAccountGroupPriceLists) {
            //Find the CC Price List in the map
            ccrz__E_PriceList__c pl = newCCPriceListMap.get(agpl.ccrz__AccountGroup__c);
            if (pl != null && agpl.ccrz__Pricelist__c == null) {
                //Populate the CC Price List Id on the CC Acount Group Price List record
                agpl.ccrz__Pricelist__c = pl.Id;
                //Find the quote so that it can be added to the map.
                SBQQ__Quote__c quote = accountGroupToQuoteMap.get(agpl.ccrz__AccountGroup__c);
                //Create a map to associate the quote to the pricelist
                quoteToPriceListMap.put(quote.Id, pl.Id);  
            }
        }

        //Create the CC Account Group Price List Records
        mappingUtils.performUpsert(CPQB2BProcessType.Pricing.name(), ccAccountGroupPriceLists);

        return quoteToPriceListMap;
    }

    /**
     * @description This method creates a map of CPQ Quote to CC Price Lists
     *              This includes logic that will create account groups, account group price lists, and CC Price List
     * @param List<SBQQ__Quote__c> quotes
     * @return Map<Id, Id> Quote Id -> Price List Id
     */
    public Map<Id, Id> getQuoteToPriceListMap(List<SBQQ__Quote__c> quotes) {
        //Map Quote Id -> Quote
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(); 
        List<ccrz__E_AccountGroup__c> accountGroups = new List<ccrz__E_AccountGroup__c>();
        //Map AccountId -> ccrz__E_AccountGroup__c
        Map<Id,ccrz__E_AccountGroup__c> accountToAccountGroupMap = new Map<Id,ccrz__E_AccountGroup__c>();
        //Iterate through quotes to populate accountGroups
        for (SBQQ__Quote__c quote : quotes) {
            // Quote Id -> Quote
            quoteMap.put(quote.Id, quote);
            
            // Check to see if an account group exists and if it doesnt, we need to create it
            if (quote.SBQQ__Account__r.ccrz__E_AccountGroup__c == null) {
                ccrz__E_AccountGroup__c accountGroup = new ccrz__E_AccountGroup__c();
                accountGroup.Name = quote.SBQQ__Account__r.Name;
                //create a map for the account group and match by name for now
                //we will insert all the records at once and then we will have to set the id
                accountToAccountGroupMap.put(quote.SBQQ__Account__c, accountGroup);
            }  else {
                accountToAccountGroupMap.put(quote.SBQQ__Account__c, new ccrz__E_AccountGroup__c(
                    Id=quote.SBQQ__Account__r.ccrz__E_AccountGroup__c,
                    Name=quote.SBQQ__Account__r.ccrz__E_AccountGroup__r.Name));
            }
        }

        if (!accountToAccountGroupMap.IsEmpty()) {
            //insert all of the new account groups     
            mappingUtils.performUpsert(CPQB2BProcessType.Pricing.name(), accountToAccountGroupMap.values());
        }
       
        //Map: Account Id => Account
        Map<Id, Account> accountMap = setAccountGroupAccounts(accountToAccountGroupMap); 
        //Get all of the price lists for the account group
        Map<Id, List<ccrz__E_PriceList__c>> ccAccountGroupPriceListMap = getPriceListsByAccountGroup(accountToAccountGroupMap);

        return getOrCreatePriceListIdsByQuoteIds(quotes, accountMap, accountToAccountGroupMap, ccAccountGroupPriceListMap);
    }
    
    /**
     * @description Create a CC Price List From an Account Group
     *              
     * @param ccrz__E_AccountGroup__c accountGroup
     * @return ccrz__E_PriceList__c Pricelist
     */
    public ccrz__E_PriceList__c createAccountGroupPriceList(ccrz__E_AccountGroup__c accountGroup, String currencyType) {     
        Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
        //Create the CC Price List
        ccrz__E_PriceList__c ccPriceList = new ccrz__E_PriceList__c();
        ccPriceList.Name = accountGroup.Name;
        ccPriceList.ccrz__CurrencyISOCode__c = currencyType;

        if (isMultiCurrency) {
            ccPriceList.put('CurrencyIsoCode', currencyType);
        }
        return ccPriceList;
    }

    /**
     * @description Delete a list of cc price list items
     *              
     * @param List<ccrz__E_PriceListItem__c> priceListItems
     */
    public void deletePriceListItems(List<ccrz__E_PriceListItem__c> priceListItems) {
        if (!priceListItems.IsEmpty()) {
            try {
                Database.DeleteResult[] dsrs = Database.Delete(priceListItems, false);
                logger.log(CPQB2BProcessType.Pricing.name(), this.triggerEvent, dsrs, priceListItems);   
            } catch (Exception e) {
                logger.log(CPQB2BProcessType.Pricing.name(),this.triggerEvent, e , priceListItems);          
            } finally{
                logger.write();
            } 
        }
    }

    /**
     * @description This method determines if there associated price list item for a price book entry
     * that should be deleted
     * @param PriceBookEntry priceBookEntry
     * @return Boolean
     */
    public Boolean isCCPriceListItemExpired(PriceBookEntry priceBookEntry) {
        return !priceBookEntry.IsActive || !priceBookEntry.Product2.IsActive || !priceBookEntry.PriceBook2.IsActive;
    }
}