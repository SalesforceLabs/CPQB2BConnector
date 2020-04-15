/**
* @author Ashlee Zeigler
* @date 3-1-2020
*
* @see CPQB2BSelector
* @description Selector class for User 
*/
public class CPQB2BUserSelector extends CPQB2BSelector {
    /*******************************************************************************************************
       * @description Constructor that sets SObjectType
       */  
       public CPQB2BUserSelector() {
           super(Schema.User.SObjectType);
       }
   
       /*******************************************************************************************************
       * @description Returns a Set that has all of the default fields. 
       * @return Set of Strings that contain the default fields for this object
       */
       public override Set<String> getDefaultFields() {
           return new Set<String>{
               'Id',
               'ContactId',
               'Name',
               'ccrz__CC_CurrencyCode__c'
           };
       }
   
       /*******************************************************************************************************
        * @description Returns a List of Users By ContactIds
        * @param Set<Id> ids
        * @return  List<User>
        */
       public List<User> getByContactIds(List<Id> ids) {
           List<String> queryFields = new List<String>(this.getDefaultFields());
   
           String query = 'SELECT ' + String.join(queryFields, ',');
           query += ' FROM User';
           query += ' WHERE ContactId IN :ids';
           query += ' AND IsActive = true';
   
           return (List<User>)Database.query(query);
       }
   }