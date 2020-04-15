/**
* @author Ashlee Zeigler
* @date 2-18-2020
*
* @see CPQB2BSelector
* @description Selector class for CCPriceListItem
*/
public class CPQB2BCCPriceListItemSelector extends CPQB2BSelector {
 /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */  
    public CPQB2BCCPriceListItemSelector() {
        super(Schema.ccrz__E_PriceListItem__c.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields. 
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'ccrz__EndDate__c',
            'ccrz__Price__c',
            'ccrz__Pricelist__c',
            'ccrz__Pricelist__r.ccrz__CurrencyISOCode__c',
            'ccrz__Product__c',
            'ccrz__StartDate__c',
            'Source_PriceBookEntry_Id__c',
            'Quote_Line__c'
        };
    }

    /**
     * getMappedFields Returns the mapped fields from custom metadata
     * @return   Set<String> of field names
     */
    public Set<String> getMappedFields() {
        Set<String> customFieldsToQuery = new Set<String>();

        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getCustomQuoteLineFieldMappings();
        if(fieldMappings != null){
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                if (fieldMap.destField != null) {
                    customFieldsToQuery.add(fieldMap.destField);
                }
            }
        }
        return customFieldsToQuery;
    }
    
    /**
   * getMappedFields Returns the combined list of default fields and mapped fields to ensure no duplicate columns are queried
   * @return   Set<String> of field names
   */
    public Set<String> getFields() {
        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(getDefaultFields());
        fieldsToQuery.addAll(getMappedFields());
        return fieldsToQuery;
    }

    /*******************************************************************************************************
     * @description Returns a List of CCPriceListItems records by priceBookEntryIds 
     * @param Set<Id> priceBookEntryids
     * @return  List<ccrz__E_PriceList__c>
     */
    public List<ccrz__E_PriceListItem__c> getCCPriceListItemsByPriceBookEntryIds(Set<Id> priceBookEntryids) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_PriceListItem__c';
        query += ' WHERE Source_PriceBookEntry_Id__c IN :priceBookEntryids';
        query += ' AND IsDeleted = false';

        return (List<ccrz__E_PriceListItem__c>)Database.query(query);
    }

     /*******************************************************************************************************
     * @description Returns a List of CCPriceListItems records by QuoteLineIds 
     * @param Set<Id> quoteLineIds
     * @return  List<ccrz__E_PriceList__c>
     */
    public List<ccrz__E_PriceListItem__c> getCCPriceListItemsByQuoteLineIds(Set<Id> quoteLineIds) {
        List<String> queryFields = new List<String>(getFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_PriceListItem__c';
        query += ' WHERE Quote_Line__c IN :quoteLineIds';
        query += ' AND IsDeleted = false';

        return (List<ccrz__E_PriceListItem__c>)Database.query(query);
    }
}