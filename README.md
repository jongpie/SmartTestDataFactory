# Smart Test Data Factory
<br />
A lightweight library for dynamically generating Sobject records & setting any required fields, based on the field's metadata
<br />
<br />
<a href="https://githubsfdeploy.herokuapp.com" target="_blank">
     <img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Public Constructors
Two constructors are available
1. A constructor that accepts an instance of Schema.SObjectType. This constructor can be used when no additional fields need to be set to create the the record, such as custom objects with no required lookup fields or master-detail relationships.

```
TestDataFactory accountTestDataFactory = new TestDataFactory(Schema.Account.SobjectType);
TestDataFactory myCustomObjectTestDataFactory = new TestDataFactory(Schema.MyCustomObject__c.SobjectType);
```

2. A constructor that accepts an instance of an Sobject record. The record is used to set any desired field values - any other required fields are automatically set by TestDataFactory

```
Account defaultAccountValues = new Account(Name = 'My Test Account');
TestDataFactory accountTestDataFactory = new TestDataFactory(defaultAccountValues);
```

## Public Methods
Only 1 public method is available - createRecord(). This method should be called to get the resulting Sobject record. The returned Sobject will need to be cast to your specific Sobject type, instead of the generic type 'Sobject'.

```
Account defaultAccountValues = new Account(Name = 'My Test Account');
Account account = (Account)new TestDataFactory(defaultAccountValues).createRecord();
```