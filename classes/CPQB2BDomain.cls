/**
 * An alternative approach to the Domain pattern advocated by Apex Enterprise Patterns from FF-Lib Commons
 * <p>
 * The domain pattern defines an approach to Apex code organization that advocates placing
 * all logic specific to an object into a "Domain" class for that object. For example,
 * "AccountDomain.cls" would be the only class containing logic for manipulating data
 * from the standard Account object in Salesforce. This promotes code re-use, maintainability,
 * and simpler organization. The Domain class and sub-types extending this class should
 * NOT define methods that perform database queries. Those method should be placed
 * in a separate Selector class.
 * <p>
 * This base Domain class defines data and behavior for all sub-types to implement. Specifically,
 * the base Domain class defines trigger event methods that should be overridden by a sub-class.
 * <p>
 * This class is a modified version that does not leverage the CRUD/FLS "SecUtil" class for automatic 
 * validation of CRUD. If you have a trigger that modifies a field, then you need to manually check the 
 * security of that field.
 * <p>
 * See ExampleAccountDomain and ExampleAccountTrigger for an example of how to use this.
 * 
 * @todo: Provide mechanism for bypassing triggers
 *
 * @credit FinancialForce  "Apex Enterprise Patterns". Using some of the ideas in their Domain class here.
 * @author Eddie Blazer, CodeScience
 * @date January 14th, 2015
 */
public abstract class CPQB2BDomain {
	private Type myType;
	private SObjectType mySOType;
	private Schema.DescribeSObjectResult mySODescribe;
	protected Boolean stateful;
	public  List<SObject> records {get; private set;} //

	protected CPQB2BDomain(List<SObject> records) {
		init(records);
	}

	protected virtual void init(List<SObject> records) {
		this.stateful 		= true;
		this.records		= records;
		this.mySOType		= records.getSObjectType();
		this.mySODescribe	= this.mySOType.getDescribe();
	}

	/**
	 * @return The SObjectType of the object that this Domain works with.
	 */
	public Schema.SObjectType getSObjectType() {
		return this.mySOType;
	}
	
	/**
	 * @return The API name of the object that this Domain works with.
	 */
	public String getSObjectName() {
		return this.mySODescribe.getName();
	}
	
	/**
	 * @return The API name of this domain class.
	 */
	public String getDomainLayerName() {
		return this.myType.getName();
	}

	/*
		Sub-Types should override the following methods as needed
	*/
	public virtual void onApplyDefaults() {}
	public virtual void onValidate() {}
	
	public virtual void onBeforeInsert() {}
	public virtual void onBeforeUpdate(Map<Id,SObject> oldMap) {}
	public virtual void onBeforeDelete() {}
	
	public virtual void onAfterInsert() {}
	public virtual void onAfterUpdate(Map<Id,SObject> oldMap) {}
	public virtual void onAfterDelete() {}
	public virtual void onAfterUndelete() {}
	

	private void handleBeforeInsert() {
		onApplyDefaults();
		onBeforeInsert();
	}
	private void handleBeforeUpdate() {
		onBeforeUpdate(Trigger.oldMap);
	}
	private void handleBeforeDelete() {
		onBeforeDelete();
	}
	private void handleAfterInsert() {	
		onValidate();
		onAfterInsert();
	}
	private void handleAfterUpdate() {
		onValidate();
		onAfterUpdate(Trigger.oldMap);
	}
	private void handleAfterDelete() {
		onAfterDelete();
	}
	private void handleAfterUndelete() {
		onAfterUndelete();
	}

	/**
	 * Invoke the trigger handler framework.
	 * <p>
	 * This method can only be called by a Trigger. The trigger should specify the
	 * Apex class that implements the trigger logic.
	 *
	 * @param handler 
	 *
	 */
	public static void triggerHandler(Type handler) {
		if (handler == null || !Trigger.isExecuting) {
			return;
		}

		// Ignore Non-Connector Users
		if(!FeatureManagement.checkPermission('CPQB2BConnectorUser')){
			return;
		}

		List<SObject> data  = Trigger.isDelete ? Trigger.old : Trigger.new;

		CPQB2BDomain d = (CPQB2BDomain)JSON.deserialize('{}', handler); // Ugly hack to instantiate an object instance that has no default constructor
		d.init(data);
			
		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
				d.handleBeforeInsert();
			} else if (Trigger.isUpdate) {
				d.handleBeforeUpdate();
			} else if (Trigger.isDelete) {
				d.handleBeforeDelete();
			}
		} else if (Trigger.isAfter) {
			if (Trigger.isInsert) {
				d.handleAfterInsert();
			} else if (Trigger.isUpdate) {
				d.handleAfterUpdate();
			} else if (Trigger.isDelete) {
				d.handleAfterDelete();
			} else if(Trigger.isUnDelete) {
				d.handleAfterUnDelete();
			}
		}
	}
}