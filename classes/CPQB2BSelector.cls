/**
 * An alternative approach to the Selector pattern advocated by Apex Enterprise Patterns from FF-Lib Commons
 * <p>
 * The selector pattern defines an approach to Apex code organization that advocates placing
 * all database queries specific to an object into a "Selector" class for that object. For example,
 * "AccountSelector.cls" would be the only class containing SOQL queries for retrieving data
 * from the standard Account object in Salesforce. This promotes code re-use, maintainability,
 * and simpler organization. The Selector class and sub-types extending this class should
 * NOT define methods that perform write-type database operations. Those method should be placed
 * in a separate Domain class.
 * <p>
 * This base Selector class defines data and behavior for all sub-types to implement.
 * Additionally, this class defines some simple helper methods for retrieving records from
 * the database, by RecordId or for retrieving all records (limit of 2000).
 * <p>
 * This is a modified Selector class that has removed usage the CRUD/FLS "Data" framework for automatic 
 * validation of CRUD, FLS, and sharing rules.
 * <p>
 * See ExampleAccountSelector for an example.
 * 
 * @credit FinancialForce  "Apex Enterprise Patterns". Using some of the ideas in their Selector class here.
 * @author Eddie Blazer, CodeScience
 * @date January 7th, 2015
 * @author Bobby Tamburrino, CodeScience
 * @date December 27, 2018
 */
public abstract class CPQB2BSelector {
	private Schema.SObjectType soType;
	
	/**
	 * This constructor is the same as calling <code>Selector(Schema.SObjectType sot, true, true, true);</code>.
	 */
	protected CPQB2BSelector(Schema.SObjectType sot) {
		this.soType	= sot;
	}

	/**
	 * Retrieve the standard, default fields used for queries to the object
	 * <p>
	 * Sub-type implementations are required to define this method. This method is used by
	 * the default <code>getAllRecords()</code> and <code>getRecordBy()</code> methods.
	 * <p>
	 * Supports parent relationship fields, but not sub-queries.
	 *
	 * @return Set<String> A set of fully qualified field names to retrieve when querying the underlying SObject.
	 */
	public abstract Set<String> getDefaultFields();
	
	/**
	 * @return The SObjectType of the object that this Selector works with.
	 */
	public Schema.SObjectType getSObjectType() {
		return this.soType;
    }
    
    /**
	 * @return The API name of the object that this Selector works with.
	 */
	public String getSObjectName() {
		return this.getSObjectType().getDescribe().getName();
	}

	/**
	 * Automatically builds a SOQL query that uses all fields defined by
	 * <code>getDefaultFields()</code> for the defined SObject. This method does
	 * not append any filters, orders, limits, etc.
	 * 
	 * @return String the default SOQL query
	 */
	public String getDefaultQuery() {
		return getQuery(this.getDefaultFields());
	}

	/**
	 * Builds a SOQL query that uses all the fields passed in. Does not append filters, orders, limits, etc
	 * This replaces the old getDefaultQuery so we can manipulate the SELECT string sometimes
	 * @param  queryFields String Set of fields
	 * @return             The SQOL query
	 */
	public String getQuery(Set<String> queryFields) {
		queryFields.add('Id');

		List<String> fieldList = new List<String>(queryFields);

		String query = String.format('SELECT {0} FROM {1} ', new List<String>{String.join(fieldList, ', '), this.getSObjectName()});

		return query;
	}

	
	/**
	 * @return List<SObject> all records as retrieved by the database.
	 */
	public virtual List<SObject> getAllRecords() {
		String query = this.getDefaultQuery();
		query += 'LIMIT 2000';
		return Database.query(query);
	}

	/**
	 * Gets the specified record with the specified fields
	 * @param  recordId       Record ID
	 * @param  queryFields    String Set of fields to query
	 * @param  includeDefault TRUE if we are also to get the default fields
	 * @return                The specified record or null
	 */
	public virtual SObject getRecordById(Id recordId, Set<String> queryFields, Boolean includeDefault) {
		SObject returnValue;
		
		if (recordId != null && recordId.getSobjectType() == this.soType) {
			Set<String> fieldSet = new Set<String>(queryFields);
			if (includeDefault) {
				fieldSet.addAll(this.getDefaultFields());
			}
			String query = getQuery(fieldSet);
			query += 'WHERE Id = :recordId LIMIT 1';

			List<SObject> records = Database.query(query);

			if (records != null && records.size() == 1) {
				returnValue = records.get(0);
			}
		}
		
		return returnValue;
	}

	public virtual SObject getRecordById(Id recordId, Set<String> queryFields) {
		return getRecordById(recordId, queryFields, false);
	}
	public virtual SObject getRecordById(Id recordId) {
		return getRecordById(recordId, new Set<String>(), true);
	}

	/**
	 * Gets the specified records with the specified fields
	 * @param  recordId       Set of Record IDs
	 * @param  queryFields    String Set of fields to query
	 * @param  includeDefault TRUE if we are also to get the default fields
	 * @return                The specified record or null
	 */
	public virtual List<SObject> getRecordsByIds(Set<Id> recordIds, Set<String> queryFields, Boolean includeDefault) {
		List<SObject> returnValue;
		
		if (recordIds != null) {
			Set<String> fieldSet = new Set<String>(queryFields);
			if (includeDefault) {
				fieldSet.addAll(this.getDefaultFields());
			}
			String query = getQuery(fieldSet);
			query += 'WHERE Id IN :recordIds';

			returnValue = Database.query(query);
		}
		
		return returnValue;
	}

	public virtual List<SObject> getRecordsByIds(Set<Id> recordIds, Set<String> queryFields) {
		return getRecordsByIds(recordIds, queryFields, false);
	}
	public virtual List<SObject> getRecordsByIds(Set<Id> recordIds) {
		return getRecordsByIds(recordIds, new Set<String>(), true);
	}

	/**
	 * Uses SOQL to search for a record. This is not as performant as using the "findRecords..."
	 * methods, but is left here for backwards compatability.
	 */
	//@deprecated
	public virtual List<SObject> getRecordSearchResultsByName(String name) {
		String query 	= getDefaultQuery();
		query 			+= ' WHERE Name LIKE :name';
		return Database.query(query);
	}
}