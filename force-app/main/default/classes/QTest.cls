/**
* QTest is used to test Q logic
* @author  Jean-Philippe Monette
* @since   2017-03-21
*/
@IsTest
private class QTest {

    @IsTest
    static void testConstructor() {
        String query =
            new Q(Account.SObjectType)
                .build();

        System.assertEquals('SELECT Id FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testAddSubQuery() {
        String query =
            new Q(Account.SObjectType)
                .addSubquery(new Q('Contacts'))
                .build();

        System.assertEquals('SELECT (SELECT Id FROM Contacts) FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testSelectFieldsUsingFieldSet() {
        // skip this test of the org doesn't have the example fieldset
        if (!Schema.SObjectType.Account.fieldSets.getMap().containsKey('Example')) {
            return;
        }
        String query =
            new Q(Account.SObjectType)
                .selectFields(SObjectType.Account.fieldSets.getMap().get('Example'))
                .build();

        System.assertEquals('SELECT CreatedById, Description, Owner.Email FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testSelectFieldsUsingSetString() {
        String query =
            new Q(Account.SObjectType)
                .selectFields(new Set<String>{'CreatedById', 'Description', 'Owner.Email'})
                .build();

        System.assertEquals('SELECT CreatedById, Description, Owner.Email FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testAddOrders() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.orderBy('Name').nullsLast())
                .add(Q.orderBy('BillingCountry').descending())
                .build();

        System.assertEquals('SELECT Id FROM Account ORDER BY Name ASC NULLS LAST, BillingCountry DESC', query);
        Database.query(query);
    }

    @IsTest
    static void testAddCondition1() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.condition('BillingCountry').isNotNull())
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE BillingCountry != null', query);
        Database.query(query);
    }

    @IsTest
    static void testAddCondition2() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.condition('Name').isLike('%Acme%'))
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE Name LIKE \'%Acme%\'', query);
        Database.query(query);
    }

    @IsTest
    static void testAddLimit() {
        String query =
            new Q(Account.SObjectType)
                .addLimit(5)
                .build();

        System.assertEquals('SELECT Id FROM Account LIMIT 5', query);
        Database.query(query);
    }

    @IsTest
    static void testAddOffset() {
        String query =
            new Q(Account.SObjectType)
                .addOffset(5)
                .build();

        System.assertEquals('SELECT Id FROM Account OFFSET 5', query);
        Database.query(query);
    }

    @IsTest
    static void testBindVariable() {
        List<String> listOfNames = new List<String> {'Acme', 'Acme 2'};
        String query =		
            new Q(Account.SObjectType)
                .add(Q.condition('Name').isIn(Q.bindVar(':listOfNames')))
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE Name IN :listOfNames', query);
        Database.query(query);
    }
  
    @IsTest
    static void testGroupBy() {
        String query =
            new Q(Lead.SObjectType)
        .selectFields(new Set<String>{'LeadSource', 'COUNT(Name)'})
                .groupBy('LeadSource')
                .build();

        System.assertEquals('SELECT LeadSource, COUNT(Name) FROM Lead GROUP BY LeadSource', query);
        Database.query(query);
    }

    @IsTest
    static void testBindVariableException() {
        List<String> listOfNames = new List<String> {'Acme', 'Acme 2'};
        Boolean bindExceptionThrown = false;
        try {
            String query =		
            new Q(Account.SObjectType)
                .add(Q.condition('Name').isIn(Q.bindVar('listOfNames')))
                .build();
        } catch (QBindVariable.QBindVariableException e) {
            bindExceptionThrown = true;
        }
        
        System.assertEquals(true, bindExceptionThrown);		
    }

    @IsTest
    static void testGroupByMultiple() {
        String query =
            new Q(Lead.SObjectType)
                .selectFields(new Set<String>{'Status', 'LeadSource', 'COUNT(Name)'})
                .groupBy(new Set<String>{'Status', 'LeadSource'})
                .build();

        System.assertEquals('SELECT Status, LeadSource, COUNT(Name) FROM Lead GROUP BY Status, LeadSource', query);
        Database.query(query);
    }

    @IsTest
    static void testOrGroup() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.orGroup()
                    .add(Q.condition('Name').isEqualTo('test'))
                    .add(Q.condition('Name').isEqualTo('test'))
                )
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE (Name = \'test\' OR Name = \'test\')', query);
        Database.query(query);

        List<QCondition> conditions = new List<QCondition>();
        conditions.add(Q.condition('Name').isEqualTo('test'));
        conditions.add(Q.condition('Name').isEqualTo('test'));
        QOrGroup sbOrGroup = new QOrGroup(conditions);
        query =
            new Q(Account.SObjectType)
                .add(sbOrGroup)
                .build();

        System.assertEquals(true, sbOrGroup.hasConditions);
        System.assertEquals('SELECT Id FROM Account WHERE (Name = \'test\' OR Name = \'test\')', query);
        Database.query(query);
    }

    @IsTest
    static void testAndGroup() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.andGroup()
                    .add(Q.condition('Name').isEqualTo('test'))
                    .add(Q.condition('Name').isEqualTo('test'))
                )
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE (Name = \'test\' AND Name = \'test\')', query);
        Database.query(query);

        List<QCondition> conditions = new List<QCondition>();
        conditions.add(Q.condition('Name').isEqualTo('test'));
        conditions.add(Q.condition('Name').isEqualTo('test'));
        QAndGroup sbAndGroup = new QAndGroup(conditions);
        query =
            new Q(Account.SObjectType)
                .add(sbAndGroup)
            .build();

        System.assertEquals('SELECT Id FROM Account WHERE (Name = \'test\' AND Name = \'test\')', query);
        Database.query(query);
    }

    @IsTest
    static void testHaving() {
        String query =
            new Q(Lead.SObjectType)
                .selectFields(new Set<String>{'LeadSource', 'COUNT(Name)'})
                .groupBy('LeadSource')
                .havingCondition(Q.condition('COUNT(Name)').isGreaterThan(0))
                .build();

        System.assertEquals('SELECT LeadSource, COUNT(Name) FROM Lead GROUP BY LeadSource HAVING COUNT(Name) > 0', query);
        Database.query(query);
    }

    @IsTest
    static void testDistance() {

        String query =
            new Q(Account.SObjectType)
                .add(Q.distanceFrom('BillingAddress').to(37.775, -122.418).isLessThan(20))
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE DISTANCE(BillingAddress, GEOLOCATION(37.775, -122.418), \'mi\') < 20', query);
        Database.query(query);
    }

    @IsTest
    static void testIsInSubQuery() {        
        String query =		
            new Q(Account.SObjectType)
                .add(Q.condition('Name').isIn(new Q(Account.SObjectType).selectFields(new Set<String> {'Name'})))
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE Name IN (SELECT Name FROM Account)', query);
    }

    @IsTest
    static void testIsNotInSubQuery() {        
        String query =		
            new Q(Account.SObjectType)
                .add(Q.condition('Name').isNotIn(new Q(Account.SObjectType).selectFields(new Set<String> {'Name'})))
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE Name NOT IN (SELECT Name FROM Account)', query);
    }

    @IsTest
    static void testTypeOf() {
        String query =
            new Q(Event.SObjectType)
                .selectFields(Q.typeOf('What')
                    .when('Account').then(new Set<String> {'Phone', 'NumberOfEmployees'})   
                    .when('Opportunity').then(new Set<String> {'Amount', 'CloseDate'})                 
                    .otherwise(new Set<String> {'Name', 'Email'})
                )
                .build();

        String expected = 'SELECT ' + 
                            'TYPEOF What ' +
                            'WHEN Account THEN Phone,NumberOfEmployees ' +
                            'WHEN Opportunity THEN Amount,CloseDate ' +
                            'ELSE Name,Email ' +
                            'END ' +
                        'FROM Event';

        System.assertEquals(expected, query);
        Database.query(query);
    }
}