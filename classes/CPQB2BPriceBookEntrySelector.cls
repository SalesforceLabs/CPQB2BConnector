/**
* @author Ashlee Zeigler
* @date 2-17-2020
*
* @see CPQB2BSelector
* @description Selector class for PriceBookEntry
*/
public class CPQB2BPriceBookEntrySelector extends CPQB2BSelector {
    /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */  
    public CPQB2BPriceBookEntrySelector() {
        super(Schema.PriceBookEntry.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields. 
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'PriceBook2Id',
            'UnitPrice',
            'IsActive',
            'Product2Id',
            'ProductCode',
            'Product2.IsActive',
            'Product2.Sync_Product_To_B2B__c',
            'PriceBook2.IsActive'
        };
    }

    /*******************************************************************************************************
     * @description Returns a single PriceBookEntry record by id 
     * @param Id priceBookEntryId
     * @return  PriceBookEntry
     */
    public PriceBookEntry getPricebookEntryById(Id priceBookEntryId) {
        List<String> queryFields = new List<String>(this.getDefaultFields());
        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('CurrencyIsoCode');
        }

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM PriceBookEntry';
        query += ' WHERE Id = :priceBookEntryId';
        query += ' AND IsDeleted = false';

        List<PriceBookEntry> results = (List<PriceBookEntry>)Database.query(query);
        if (results.size() == 1) {
            return results[0];
        }
        return null;
    }

    /*******************************************************************************************************
     * @description Returns a List of PriceBookEntry records by ids
     * @param List<Id> priceBookEntryIds 
     * @return  List<PriceBookEntry>
     */
    public List<PriceBookEntry> getPricebookEntryByIds(List<Id> priceBookEntryIds) {
        List<String> queryFields = new List<String>(this.getDefaultFields());
        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('CurrencyIsoCode');
        }
        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM PriceBookEntry';
        query += ' WHERE Id IN :priceBookEntryIds';
        query += ' AND IsDeleted = false';
        query += ' AND IsActive = true';

        return (List<PriceBookEntry>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Get the PriceBookEntry QueryLocator for records that have not been synced
     *   
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator getPriceListEntryItemsToSync() {
        List<String> queryFields = new List<String>(this.getDefaultFields());
        if (UserInfo.isMultiCurrencyOrganization()) {
            queryFields.add('CurrencyIsoCode');
        }
        DateTime lastModifiedDate = Datetime.now().addDays(-1);

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM PriceBookEntry';
        query += ' WHERE SystemModStamp > :lastModifiedDate';
        query += ' AND IsDeleted = false';

        return Database.getQueryLocator(query);
    }
}