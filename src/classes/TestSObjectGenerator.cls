/***********************************************************************************************************
* This file is part of the Simple Trigger handler project, released under the MIT License.                 *
* See LICENSE file or go to https://github.com/jongpie/SmartTestSObjectGenerator for full license details. *
***********************************************************************************************************/
public virtual class TestSObjectGenerator {

    private class TestSObjectGeneratorException extends Exception {}

    private static final Organization ORGANIZATION = [SELECT IsSandbox, OrganizationType FROM Organization LIMIT 1];
    private static final Map<Schema.SObjectType, List<Schema.SObjectField>> REQUIRED_FIELDS_BY_SOBJECT_TYPE = new Map<Schema.SObjectType, List<Schema.SObjectField>>();

    protected final SObject record;
    protected final List<Schema.SObjectField> requiredFields;

    public TestSObjectGenerator(Schema.SObjectType sobjectType) {
        this(sobjectType.newSObject());
    }

    public TestSObjectGenerator(SObject record) {
        this.validateEnvironment();

        this.record         = record;
        this.requiredFields = this.getRequiredFields(record.getSObjectType());
    }

    public SObject populateRequiredFields() {
        this.setDefaultFieldsAndValues();
        this.setRequiredFieldsOnRecord();
        return this.record;
    }

    protected virtual Map<Schema.SObjectField, Object> getDefaultFieldsAndValues() {
        return new Map<Schema.SObjectField, Object>();
    }

    private void validateEnvironment() {
        // Prevents accidentally generating test data in production
        if(Test.isRunningTest()) return;
        if(ORGANIZATION.IsSandbox) return;
        if(ORGANIZATION.OrganizationType == 'Developer Edition') return;

        throw new TestSObjectGeneratorException('Cannot generate test records in production');
    }

    private void setDefaultFieldsAndValues() {
        for(Schema.SObjectField field : this.getDefaultFieldsAndValues().keySet()) {
            Object fieldValue = this.getDefaultFieldsAndValues().get(field);

            this.record.put(field, fieldValue);
        }
    }

    private List<Schema.SObjectField> getRequiredFields(Schema.SObjectType sobjectType) {
        // Use cached list if present
        if(REQUIRED_FIELDS_BY_SOBJECT_TYPE.containsKey(sobjectType)) {
            System.debug(LoggingLevel.FINEST, 'Using cached list of required fields for SObject Type: ' + sobjectType);
            return REQUIRED_FIELDS_BY_SOBJECT_TYPE.get(sobjectType);
        }

        System.debug(LoggingLevel.FINEST, 'Calculating list of required fields for SObject Type: ' + sobjectType);

        List<Schema.SObjectField> requiredFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField field : sobjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            // Guard clauses for fields that aren't required
            if(fieldDescribe.isCreateable() == false) continue;
            if(fieldDescribe.isNillable() == true) continue;

            // If a field is not nillable & it is createable, then it's required
            requiredFields.add(field);
        }

        // Cache the list for any subsequent calls for this same sobject type
        REQUIRED_FIELDS_BY_SOBJECT_TYPE.put(sobjectType, requiredFields);

        return requiredFields;
    }

    private void setRequiredFieldsOnRecord() {
        Map<String, Object> populatedFields = this.record.getPopulatedFieldsAsMap();
        for(Schema.SObjectField field : this.requiredFields) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            // If a field was already populated by using the constructor 'TestSObjectGenerator(SObject record)', then don't change it
            if(populatedFields.containsKey(fieldDescribe.getName())) continue;

            Object fieldValue;
            // If there is a default value setup for the field, use it
            if(fieldDescribe.getDefaultValue() != null) fieldValue = fieldDescribe.getDefaultValue();
            // Otherwise, we'll generate our own test value to use, based on the field's metadata
            else fieldValue = this.getTestValue(fieldDescribe);

            // If we now have a value to use, set it on the record
            if(fieldValue != null) this.record.put(field, fieldValue);
        }
    }

    private Object getTestValue(Schema.DescribeFieldResult fieldDescribe) {
        // Some more complex data types, like ID & Reference, require other objects to be created
        // This implementation delegates that responsibility to the test classes since DML is required to get a valid ID,
        // but the logic below could be updated to support creating parent objects if needed

        // Unsupported display types have been commented-out below
        /*
            Schema.DisplayType.Address, Schema.DisplayType.AnyType, Schema.DisplayType.Base64,
            Schema.DisplayType.DataCategoryGroupReference, Schema.DisplayType.Id, Schema.DisplayType.Reference
        */
        switch on fieldDescribe.getType() {
            when Boolean         { return false; }
            when Combobox        { return this.getStringValue(fieldDescribe); }
            when Currency        { return 19.85; }
            when Date            { return System.today(); }
            when DateTime        { return System.now(); }
            when Double          { return 3.14; }
            when Email           { return 'test@example.com'; }
            when EncryptedString { return this.getStringValue(fieldDescribe); }
            when Integer         { return 1; }
            when MultiPicklist   { return fieldDescribe.getPicklistValues()[0].getValue(); }
            when Percent         { return 0.42; }
            when Phone           { return '+1 (510) 555-1234'; }
            when Picklist        { return fieldDescribe.getPicklistValues()[0].getValue(); }
            when String          { return this.getStringValue(fieldDescribe); }
            when TextArea        { return this.getStringValue(fieldDescribe); }
            when Time            { return Time.newInstance(13, 30, 6, 20); }
            when Url             { return 'https://salesforce.com'; }
            when else            { return null; } // Any non-supported display types will return null - test classes will need to handle setting the values
        }
    }

    private String getStringValue(Schema.DescribeFieldResult fieldDescribe) {
        String strValue   = 'Test string for ' + fieldDescribe.getName();
        Integer maxLength     = fieldDescribe.getLength();

        return strValue.length() <= maxLength ? strValue : strValue.left(maxLength);
    }

}