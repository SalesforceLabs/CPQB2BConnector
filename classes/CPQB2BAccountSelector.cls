/**
* @author Ashlee Zeigler
* @date 2-20-2020
*
* @see CPQB2BSelector
* @description Selector class for CCAccountGroupSelector 
*/
public class CPQB2BAccountSelector extends CPQB2BSelector {
 /*******************************************************************************************************
    * @description Constructor that sets SObjectType
    */  
    public CPQB2BAccountSelector() {
        super(Schema.Account.SObjectType);
    }

    /*******************************************************************************************************
    * @description Returns a Set that has all of the default fields. 
    * @return Set of Strings that contain the default fields for this objec
    */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'ccrz__E_AccountGroup__c',
            'Name'
        };
    }

    /*******************************************************************************************************
     * @description Returns a List of Accounts By
     * @param Set<Id> ids
     * @return  List<ccrz__E_AccountGroupPriceList__c>
     */
    public List<Account> getAccountsByIds(Set<Id> ids) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM Account';
        query += ' WHERE id IN :ids';
        query += ' AND IsDeleted = false';

        return (List<Account>)Database.query(query);
    }
}