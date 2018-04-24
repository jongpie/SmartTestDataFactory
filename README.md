# Smart Test Data Factory
<br />
An Apex library for dynamically setting any required fields on an Sobject record, based on the field's metadata
<br />
<br />
<a href="https://githubsfdeploy.herokuapp.com" target="_blank">
     <img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Overview
This library simplifies the process of creating of test records in Salesforce. It can be leveraged in Apex unit tests to automatically set field values for any required field. This is useful when you need to insert records but the exact field values are not relevant to your tests.

> **Note**: Lookup & master-detail fields are **not** set by this library - you must set these fields yourself before you insert your record.

## Usage
1. **Create your Sobject** You can provide an empty record (`new Account()`), or you can set your own values for any field values that are important to your tests (`new Account(Type='Prospect')`).
2. **Create a new instance of TestDataFactory by passing your record in the constructor** When you're ready, call populateRequiredFields() to set values for any null required fields.

```
Account testAccount = new Account();
new TestDataFactory(testAccount).populateRequiredFields();
System.assertNotEquals(null, testAccount.Name);
insert testAccount;
```