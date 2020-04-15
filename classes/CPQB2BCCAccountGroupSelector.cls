/**
* @author Amil Abdallah
* @date 3-06-2020
*
* @see CPQB2BSelector
* @description Selector class for CCAccountGroupSelector 
*/
public class CPQB2BCCAccountGroupSelector extends CPQB2BSelector {
    /*******************************************************************************************************
     * @description Constructor that sets SObjectType
     */  
    public CPQB2BCCAccountGroupSelector() {
        super(Schema.Account.SObjectType);
    }

    /*******************************************************************************************************
     * @description Returns a Set that has all of the default fields. 
     * @return Set of Strings that contain the default fields for this objec
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'ccrz__PriceListSelectionMethod__c'
        };
    }

    /*******************************************************************************************************
    * @description Returns AccountGroup record related to the given Account Id
    * @param Id accountId
    * @return  ccrz__E_AccountGroup__c
    */
    public ccrz__E_AccountGroup__c getAccountGroupByAccountId(Id accountId) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        CPQB2BAccountSelector acctSelector = new CPQB2BAccountSelector();
        Account acct = (Account)acctSelector.getRecordById(accountId);
        Id acctGrpId = acct.ccrz__E_AccountGroup__c;

        String query = 'SELECT ' + String.join(queryFields, ',');
        query += ' FROM ccrz__E_AccountGroup__c';
        query += ' WHERE Id = :acctGrpId';
        query += ' LIMIT 1';

        return (ccrz__E_AccountGroup__c)Database.query(query);
    }
}