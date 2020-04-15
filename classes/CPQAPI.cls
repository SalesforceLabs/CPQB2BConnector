public with sharing class CPQAPI {

    public QuoteCalculator calc{get; set;}
    public QuoteModel model{get; set;}
    public ContractAmender amender{get; set;}

    public CPQAPI(){
        this.calc = new QuoteCalculator();
        this.model = new QuoteModel();
        this.amender = new ContractAmender();
    }
        
    public class QuoteCalculatorContext {
        public QuoteModel quote;
        public String callbackClass;
        public QuoteCalculatorContext(QuoteModel quote, String callbackClass) {
            this.quote = quote;
            this.callbackClass = callbackClass;
        }

        public QuoteCalculatorContext(QuoteModel quote) {
            this.quote = quote;
            this.callbackClass = null;
        }
    }

    public with sharing class QuoteCalculator {
        public QuoteModel calculate(QuoteModel quote) {
            QuoteCalculatorContext ctx = new QuoteCalculatorContext(quote);
            String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(ctx));
            return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        }
        public QuoteModel read(String quoteId) {
            String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
            return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        }

        public QuoteModel save(QuoteModel quote) {
            String quoteJSON = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver',JSON.serialize(quote));
            return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        }

        public void calculate(QuoteModel quote, String callbackClass) {
            QuoteCalculatorContext ctx = new QuoteCalculatorContext(quote, callbackClass);
            SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(ctx));
        }
    }

    public with sharing class ContractAmender {
        public QuoteModel load(String contractId) {
            String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
            return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        }
    }

    public class AddProductContext {
        public QuoteModel quote;
        public ProductModel[] products;
        public Integer groupKey;
        public final Boolean ignoreCalculate = true; //Must be hardcoded to true

        public AddProductContext(QuoteModel quote, ProductModel[] products, Integer groupKey) {
            this.quote = quote;
            this.products = products;
            this.groupKey = groupKey;
        }
    }

    public static QuoteModel addProduct(QuoteModel quote, ProductModel[] products, Integer groupKey) {
        AddProductContext ctx = new AddProductContext(quote, products, groupKey);
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteProductAdder', null, JSON.serialize(ctx));
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }

    public class ProductReaderContext {
        public Id pricebookId;
        public String currencyCode;
        public ProductReaderContext(Id pricebookId, String currencyCode) {
            this.pricebookId = pricebookId;
            this.currencyCode = currencyCode;
        }
    }
      
    public static ProductModel readProduct(Id productId, Id pricebookId, String currencyCode) {
        ProductReaderContext ctx = new ProductReaderContext(pricebookId, currencyCode);
        String productJSON = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader',
                productId, JSON.serialize(ctx));
        return (ProductModel) JSON.deserialize(productJSON, ProductModel.class);
    }

	public class ProductLoadContext {
		public Id pricebookId;
		public String currencyCode;
	}

	public class ConfigLoadContext {
		public QuoteModel quote;
		public ProductModel parentProduct; // Only required if the configuration must inherit Configuration Attribute values from its parent.
	}

	public class LoadRuleRunnerContext {
		public QuoteModel quote;
		public String[] dynamicOptionSkus;
		public ConfigurationModel configuration;
		public ProductModel parentProduct; // Only required if the configuration must inherit Configuration Attributes from the parent.
	}

	public class ValidationContext {
		public QuoteModel quote;
		public ConfigurationModel configuration;
		public Id upgradedAssetId;
		public String event;
	}

    public static ProductModel loadProductUsingProductAPI(Id productId, Id pricebookId) {
		ProductLoadContext context = new ProductLoadContext();
		context.currencyCode = 'USD';
		context.pricebookId = pricebookId;
		String pJson = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', productId, JSON.serialize(context));
		ProductModel pModel = (ProductModel)JSON.deserialize(pJson, ProductModel.class);
		return null;
	}

      
    // public QuoteLineGroup Model
    public class QuoteLineGroupModel {
        public SBQQ__QuoteLineGroup__c record;
        public Decimal netNonSegmentTotal;
        public Integer key;
    }


    // public QuoteLineModel
    public class QuoteLineModel {
        public SBQQ__QuoteLine__c record;
        public Boolean amountDiscountProrated;
        public Integer parentGroupKey;
        public Integer parentItemKey;
        public Integer key;
        public Boolean upliftable;
        public String configurationType;
        public String configurationEvent;
        public Boolean reconfigurationDisabled;
        public Boolean descriptionLocked;
        public Boolean productQuantityEditable;
        public Decimal productQuantityScale;
        public String dimensionType;
        public Boolean productHasDimensions;
        public Decimal targetCustomerAmount;
        public Decimal targetCustomerTotal;
    }


    // public QuoteModel
    public class QuoteModel {
        public SBQQ__Quote__c record {get; set;}
        public QuoteLineModel[] lineItems {get; set;}
        public QuoteLineGroupModel[] lineItemGroups {get; set;}
        public Integer nextKey;
        public Boolean applyAdditionalDiscountLast;
        public Boolean applyPartnerDiscountFirst;
        public Boolean channelDiscountsOffList;
        public Decimal customerTotal;
        public Decimal netTotal;
        public Decimal netNonSegmentTotal;
    }


    public class ProductModel {
        public Product2 record;
        public Id upgradedAssetId;
        public String currencySymbol;
        public String currencyCode;
        public String[] featureCategories;
        public OptionModel[] options;
        public FeatureModel[] features;
        public ConfigurationModel configuration;
        public ConfigAttributeModel[] configurationAttributes;
        public ConfigAttributeModel[] inheritedConfigurationAttributes;
        public ConstraintModel[] constraints;
    }

    public class OptionModel {
        public SBQQ__ProductOption__c record;
        public Map<String,String> externalConfigurationData;
        public Boolean configurable;
        public Boolean configurationRequired;
        public Boolean quantityEditable;
        public Boolean priceEditable;
        public Decimal productQuantityScale;
        public Boolean priorOptionExists;
        public Set<Id> dependentIds;
        public Map<String,Set<Id>> controllingGroups;
        public Map<String,Set<Id>> exclusionGroups;
        public String reconfigureDimensionWarning;
        public Boolean hasDimension;
        public Boolean isUpgrade;
        public String dynamicOptionKey;
    }
    public class FeatureModel {
        public SBQQ__ProductFeature__c record;
        public String instructionsText;
        public Boolean containsUpgrades;
    }
    public class ConstraintModel {
        public SBQQ__OptionConstraint__c record;
        public Boolean priorOptionExists;
    }

    public class ConfigurationModel {
        public Id configuredProductId;
        public Id optionId;
        public SBQQ__ProductOption__c optionData; // Editable data about the option in question, such as quantity or discount
        public SBQQ__ProductOption__c configurationData;
        public SBQQ__ProductOption__c inheritedConfigurationData;
        public ConfigurationModel[] optionConfigurations;
        public Boolean configured;
        public Boolean changedByProductActions;
        public Boolean isDynamicOption;
        public Boolean isUpgrade;
        public Set<Id> disabledOptionIds;
        public Set<Id> hiddenOptionIds;
        public Decimal listPrice;
        public Boolean priceEditable;
        public String[] validationMessages;
        public String dynamicOptionKey;
    }

    public class ConfigAttributeModel {
        public String name;
        public String targetFieldName;
        public Decimal displayOrder;
        public String colmnOrder;
        public Boolean required;
        public Id featureId;
        public String position;
        public Boolean appliedImmediately;
        public Boolean applyToProductOptions;
        public Boolean autoSelect;
        public String[] shownValues;
        public String[] hiddenValues;
        public Boolean hidden;
        public String noSuchFieldName;
        public Id myId;
    }
}