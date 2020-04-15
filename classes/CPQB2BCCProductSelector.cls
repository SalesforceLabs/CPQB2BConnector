/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @description CCProduct Selector class that handles ability to query CCProduct object by different contexts
*/
public class CPQB2BCCProductSelector extends CPQB2BSelector {
    /**
     * CPQB2BCCProductSelector Class constructor
     */
    public CPQB2BCCProductSelector() {
        super(Schema.ccrz__E_Product__c.SObjectType);
    }

    /**
     * getDefaultFields Returns the default set of fields to query against CCProduct
     * @return   Set<String> of field names
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'Source_Product__c',
            'ccrz__SKU__c',
            'ccrz__ProductStatus__c',
            'ccrz__Storefront__c',
            'ccrz__LongDesc__c'
        };
    }

    /**
     * getMappedFields Returns the set of mapped fields to query against Product2
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> productFieldMappings = CPQB2BFieldMapping.getCustomProductFieldMappings();
        if(productFieldMappings!=null){
            for(CPQB2BBaseFieldMapping fieldMap : productFieldMappings){
                customFieldsToQuery.add(fieldMap.destField);
            }
        }
        return customFieldsToQuery;
    }

    public Set<String> getFields() {
        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(getDefaultFields());
        fieldsToQuery.addAll(getMappedFields());
        return fieldsToQuery;
   }

    /**
     * getCCProductByName Retrieves CCProduct record matching the provided name
     * @param  name Name of the product to query for
     * @return      ccrz__E_Product__c record
     */
    public List<ccrz__E_Product__c> getCCProductByName(String name){
        List<String> queryFields = new List<String>(this.getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_Product__c';
        query += ' WHERE Name =: name';

        return (List<ccrz__E_Product__c>)Database.query(query);
    }

    /**
     * selectById Retrieves CCProduct record matching the provided Id
     * @param  recordId Id of the CCProduct to query for
     * @return          ccrz__E_Product__c record
     */
    public ccrz__E_Product__c selectById(Id recordId){
        Set<String> queryFields = new Set<String>(this.getFields());
        return (ccrz__E_Product__c) this.getRecordById(recordId,queryFields);
    }

    /**
     * selectByIds Retrieves CCProduct records matching the provided Ids
     * @param  recordIds List of CCProduct ids to query for
     * @return          List<ccrz__E_Product__c> records
     */
    public List<ccrz__E_Product__c> selectByIds(List<Id> recordIds){
        Set<String> queryFields = new Set<String>(this.getFields());
        Set<Id> recordIdSet = new Set<Id>(recordIds);
        return (List<ccrz__E_Product__c>) this.getRecordsByIds(recordIdSet,queryFields);
    }

    /**
     * selectBySourceIds Queries for CCProduct by Id matching a given set of Ids
     * @param  product2IdList List of CCProduct Ids to query for
     * @return                List of ccrz__E_Product__c records
     */
    public List<ccrz__E_Product__c> selectBySourceIds(List<Id> product2IdList){
        List<String> queryFields = new List<String>(this.getFields());  
        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_Product__c';
        query += ' WHERE Source_Product__c IN: product2IdList';
        return (List<ccrz__E_Product__c>)Database.query(query);
    }

    /**
     * selectByIdsWithLowestPriceListItem Queries for CCProducts with one associated pricelist item per record (to be used for quote creation)
     * The pricelist item that is retrieved is determined by the sort order of lowest price
     * @param  ccProductIdList          List of CCProduct Ids to query for
     * @return                          List of ccrz__E_Product__c records with a pricelist item record
     */
    public List<ccrz__E_Product__c> selectByIdsWithLowestPriceListItem(List<Id> ccProductIdList){
        List<String> outterQueryFields = new List<String>(this.getDefaultFields());
        List<String> innerQueryFields = new List<String>{'Id', 'ccrz__Price__c, ccrz__Pricelist__r.Source_Price_Book__c'};

        String query = 'SELECT ' + String.join(outterQueryFields, ',');
        query += ', (SELECT ' + String.join(innerQueryFields,',');
        query += ' FROM ccrz__E_PriceListItems__r';

        //Check if org is using multi-currency, if true then we grab the correct
        //currency iso code from the user record (User.ccrz__CC_CurrencyCode__c)
        //and filter for pricelist items associated to that currency only
        if (UserInfo.isMultiCurrencyOrganization()) {
            CPQB2BUserSelector userSelector = new CPQB2BUserSelector();
            User u = (User) userSelector.getRecordById(UserInfo.getUserId());
            String currencyCode = u.ccrz__CC_CurrencyCode__c;

            //If currency field is not populated for user then
            //assign default org currency.
            if(String.isBlank(currencyCode)){
                currencyCode = UserInfo.getDefaultCurrency();
            }

            query += ' WHERE CurrencyIsoCode = :currencyCode';
        }

        query += ' ORDER BY ccrz__Price__c ASC LIMIT 1)';
        query += ' FROM ccrz__E_Product__c where Id IN : ccProductIdList';

        return (List<ccrz__E_Product__c>)Database.query(query);
    }

    /**
     * selectByIdsAndPricelist Queries for CCProducts with one associated pricelist item per record (to be used for quote creation)
     * The pricelist item that is retrieved is determined by the provided pricelist id
     * @param  ccProductIdList          List of CCProduct Ids to query for
     * @param  priceListId              Id of the related pricelist to specify on the ccproduct record
     * @return                          List of ccrz__E_Product__c records with a pricelist item record
     */
    public List<ccrz__E_Product__c> selectByIdAndPriceList(List<Id> ccProductIdList, Id priceListId){
        List<String> outterQueryFields = new List<String>(this.getDefaultFields());
        List<String> innerQueryFields = new List<String>{'Id', 'ccrz__Price__c, ccrz__Pricelist__r.Source_Price_Book__c'};

        String query = 'SELECT ' + String.join(outterQueryFields, ',');
        query += ', (SELECT ' + String.join(innerQueryFields,',');
        query += ' FROM ccrz__E_PriceListItems__r';
        query += ' WHERE ccrz__Pricelist__c = :priceListId LIMIT 1)';
        query += ' FROM ccrz__E_Product__c where Id IN : ccProductIdList';

        return (List<ccrz__E_Product__c>)Database.query(query);
    }
}