/**
* @author Ashlee Zeigler
* @date 2-17-2020
*
* @see CPQB2BSelector
* @description Selector class for PriceBook
*/
public class CPQB2BPriceBookSelector extends CPQB2BSelector {
    /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */
    public CPQB2BPriceBookSelector() {
        super(Schema.PriceBook2.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields.
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'IsActive',
            'Description',
            'IsStandard'
        };
    }

    /*******************************************************************************************************
     * @description Returns a single PriceBook record by id
     * @param Id priceBookId
     * @param Boolean isMultiCurrencyOrg
     * @return  PriceBook
     */
    public PriceBook2 getPricebookById(Id priceBookId) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM PriceBook2';
        query += ' WHERE Id = :priceBookId';
        query += ' AND IsDeleted = false';

        List<PriceBook2> results = (List<PriceBook2>)Database.query(query);
        if (results.size() == 1) {
            return results[0];
        }
        return null;
    }

    /*******************************************************************************************************
     * @description Returns a PriceBook2 records by ids
     * @param List<Id> priceBookId
     * @return  List<PriceBook2>
     */
    public List<PriceBook2> getPricebooksByIds(List<Id> priceBookIds) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM PriceBook2';
        query += ' WHERE Id = :priceBookIds';
        query += ' AND IsDeleted = false';

        return (List<PriceBook2>)Database.query(query);
    }

    /*******************************************************************************************************
     * @description Returns the Standard Pricebook
     * @return  PriceBook2
     */
    public PriceBook2 getStandardPriceBook() {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM PriceBook2';
        query += ' WHERE isStandard = TRUE';
        query += ' LIMIT 1';

        return (PriceBook2)Database.query(query);
    }
}